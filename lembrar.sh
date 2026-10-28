# Funções partilhadas pelo tema.sh, fundo.sh e instalar.command (não se corre sozinho).
# 1) Perfil "Claude · Último": copia o último tema e fundo escolhidos.
# 2) Fundo padrão de cada tema: o /fundo grava a imagem no perfil do tema (ver mais abaixo).

ULTIMO_NOME="Claude · Último"
ULTIMO_GUID="022141a7-791a-567c-ba14-e8247d2dd493"
ULTIMO_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
# o nome tem de vir depois de "claude-temas.json" por ordem alfabética:
# o iTerm2 lê os arquivos por essa ordem e o perfil-pai tem de existir primeiro
ULTIMO_ARQ="$ULTIMO_DIR/claude-ultimo.json"

# identificador de cada perfil de tema (os mesmos de iterm2/temas-claude-code.json)
ultimo_guid_do_tema() {
  case "$1" in
    "Claude · Rengoku")      echo "1f258dbc-842e-5b36-9e87-52e0679d64ec" ;;
    "Claude · Lofi Cidades") echo "ba9800ac-67a0-5971-9849-8d315574f596" ;;
    "Claude · Cidade Pixel") echo "288b2bad-d8f9-52ae-8c6e-c9251e09556c" ;;
    *) return 1 ;;
  esac
}

# o tema guardado agora; se ainda não há nenhum, usa o tema do Claude Code e, por fim, a Lofi Cidades
ultimo_tema() {
  local t=""
  [ -f "$ULTIMO_ARQ" ] && t="$(sed -n 's/.*"Dynamic Profile Parent Name": *"\([^"]*\)".*/\1/p' "$ULTIMO_ARQ" | head -1)"
  if ultimo_guid_do_tema "$t" >/dev/null; then echo "$t"; return; fi
  case "$(sed -n 's/.*"theme": *"custom:\([^"]*\)".*/\1/p' "$HOME/.claude/settings.json" 2>/dev/null | head -1)" in
    rengoku)      echo "Claude · Rengoku" ;;
    cidade-pixel) echo "Claude · Cidade Pixel" ;;
    *)            echo "Claude · Lofi Cidades" ;;
  esac
}

# ultimo_guardar <perfil do tema> [imagem]
#   sem imagem: fica o fundo próprio do tema
#   imagem "":  fica sem imagem de fundo
ultimo_guardar() {
  local tema="$1" guid linha="" tmp
  guid="$(ultimo_guid_do_tema "$tema")" || return 1
  if [ $# -ge 2 ]; then
    linha=",
      \"Background Image Location\": \"$(printf '%s' "$2" | sed 's/\\/\\\\/g; s/"/\\"/g')\""
  fi
  mkdir -p "$ULTIMO_DIR" "$HOME/.claude" || return 1
  # escreve primeiro ao lado e só depois troca, para o iTerm2 nunca ler um arquivo a meio
  tmp="$HOME/.claude/.claude-ultimo.$$.tmp"
  cat > "$tmp" <<EOF || { rm -f "$tmp"; return 1; }
{
  "Profiles": [
    {
      "Name": "$ULTIMO_NOME",
      "Guid": "$ULTIMO_GUID",
      "Dynamic Profile Parent Name": "$tema",
      "Dynamic Profile Parent GUID": "$guid"$linha
    }
  ]
}
EOF
  mv -f "$tmp" "$ULTIMO_ARQ"
}

# ---------------------------------------------------------------------------
# Fundo padrão de cada tema.
# O /fundo grava a imagem escolhida no próprio perfil do tema que estás a usar
# (por exemplo "Claude · Lofi Cidades"). Assim, qualquer aba nova com esse perfil
# abre com essa imagem, seja ele o padrão do iTerm2 ou não.
# As escolhas ficam em ~/.claude/temas-fundos.txt (uma linha por tema), para não se
# perderem quando corres o instalar.command de novo.
# ---------------------------------------------------------------------------
FUNDOS_ARQ="$HOME/.claude/temas-fundos.txt"
TEMAS_ARQ="$ULTIMO_DIR/claude-temas.json"
POR_ABA_DIR="$HOME/.claude/.tema-por-aba"

# identificador desta aba do iTerm2 (o iTerm2 dá um diferente a cada aba)
aba_id() { local s="${ITERM_SESSION_ID#*:}"; s="$(printf '%s' "$s" | tr -cd 'A-Za-z0-9-')"; printf '%s' "$s"; }

# guarda o tema escolhido com o /tema nesta aba
tema_marcar() {
  local id; id="$(aba_id)"; [ -n "$id" ] || return 0
  mkdir -p "$POR_ABA_DIR" && printf '%s\n' "$1" > "$POR_ABA_DIR/$id"
  find "$POR_ABA_DIR" -type f -mtime +30 -delete 2>/dev/null   # limpa abas antigas
  return 0
}

# o tema da aba onde estás: o último /tema desta aba; senão o perfil com que a aba abriu;
# se ela abriu com o "Claude · Último", o tema que ele copia
tema_atual() {
  local id t; id="$(aba_id)"
  if [ -n "$id" ] && [ -f "$POR_ABA_DIR/$id" ]; then
    t="$(head -1 "$POR_ABA_DIR/$id")"
    if ultimo_guid_do_tema "$t" >/dev/null; then echo "$t"; return; fi
  fi
  if ultimo_guid_do_tema "$ITERM_PROFILE" >/dev/null; then echo "$ITERM_PROFILE"; return; fi
  ultimo_tema
}

# o fundo que o tema traz de origem (o do arquivo iterm2/temas-claude-code.json)
fundo_original() {
  awk -v alvo="$1" -v pasta="$PASTA" '
    /"Name":/ { n=$0; sub(/^[^:]*: *"/,"",n); sub(/".*$/,"",n) }
    /"Background Image Location":/ && n==alvo { v=$0; sub(/^[^:]*: *"/,"",v); sub(/",?[[:space:]]*$/,"",v); gsub(/__PASTA__/,pasta,v); print v; exit }
  ' "$PASTA/iterm2/temas-claude-code.json"
}

# fundo_definir <perfil do tema> <imagem>   (imagem "" = sem imagem)
# fundo_definir <perfil do tema> --original (volta ao fundo de origem)
fundo_definir() {
  local tmp="$FUNDOS_ARQ.$$.tmp"
  mkdir -p "$HOME/.claude" || return 1
  { [ -f "$FUNDOS_ARQ" ] && awk -F'\t' -v alvo="$1" '$1!=alvo' "$FUNDOS_ARQ"
    [ "$2" = "--original" ] || printf '%s\t%s\n' "$1" "$2"; } > "$tmp" && mv -f "$tmp" "$FUNDOS_ARQ"
}

# escreve os perfis dos temas no iTerm2, já com os fundos que escolheste
fundos_gerar() {
  local tmp="$HOME/.claude/.claude-temas.$$.tmp"
  mkdir -p "$ULTIMO_DIR" "$HOME/.claude" || return 1
  [ -f "$FUNDOS_ARQ" ] || : > "$FUNDOS_ARQ"
  # 1.º arquivo: as escolhas; 2.º: os perfis de origem, com o caminho desta pasta
  sed "s#__PASTA__#$PASTA#g" "$PASTA/iterm2/temas-claude-code.json" | awk -F'\t' '
    FILENAME==ARGV[1] { if (NF>=2) { v=$2; gsub(/\\/,"\\\\",v); gsub(/"/,"\\\"",v); esc[$1]=v; tem[$1]=1 } next }
    /"Name":/ { n=$0; sub(/^[^:]*: *"/,"",n); sub(/".*$/,"",n) }
    /"Background Image Location":/ && (n in tem) {
      inicio=$0; sub(/".*$/,"",inicio); fim=($0 ~ /",[[:space:]]*$/) ? "," : ""
      print inicio "\"Background Image Location\": \"" esc[n] "\"" fim; next }
    { print }
  ' "$FUNDOS_ARQ" - > "$tmp" || { rm -f "$tmp"; return 1; }
  mv -f "$tmp" "$TEMAS_ARQ"
}
