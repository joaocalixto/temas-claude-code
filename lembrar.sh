# Guarda a última escolha do /tema e do /fundo no perfil "Claude · Último" do iTerm2.
# Se esse perfil for o padrão do iTerm2, as abas e janelas novas abrem com o último
# tema e o último fundo que escolheste.
# Este arquivo não se corre sozinho: o tema.sh, o fundo.sh e o instalar.command leem-no.

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
