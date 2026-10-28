#!/bin/bash
# Troca a imagem de fundo da aba do iTerm2 onde o Claude Code está aberto e grava-a
# como fundo padrão do tema dessa aba: as abas novas desse tema abrem com ela.
# Uso: fundo.sh lista | aleatorio | nenhum | original | <parte do nome, ex.: "lisboa 2">
PASTA="$(cd "$(dirname "$0")" && pwd)"
. "$PASTA/lembrar.sh"
IMGS="$PASTA/imagens"
pedido="$*"
lista() { find "$IMGS" -name '*.png' | sed "s#^$IMGS/##" | sort; }
if [ -z "$pedido" ] || [ "$pedido" = "lista" ]; then
  echo "Fundos disponíveis:"; lista | sed 's/\.png$//; s/^/  /'; exit 0
fi

tema="$(tema_atual)"            # ex.: "Claude · Lofi Cidades"
nome_tema="${tema#Claude · }"   # ex.: "Lofi Cidades"

if [ "$pedido" = "aleatorio" ] || [ "$pedido" = "aleatório" ]; then
  img="$(lista | awk 'BEGIN{srand()} {a[NR]=$0} END{print a[int(rand()*NR)+1]}')"; caminho="$IMGS/$img"
elif [ "$pedido" = "nenhum" ] || [ "$pedido" = "tirar" ]; then
  img=""; caminho=""
elif [ "$pedido" = "original" ] || [ "$pedido" = "padrao" ] || [ "$pedido" = "padrão" ]; then
  img="--original"; caminho="$(fundo_original "$tema")"
else
  padrao="$(echo "$pedido" | tr 'A-Z' 'a-z' | sed 's/[[:space:]]\{1,\}/.*/g')"
  # prefere a imagem original; as versões "-escura" e "-robo" só quando pedidas
  img="$(lista | grep -i -- "$padrao" | awk '{print ((index($0,"-escura")||index($0,"-robo"))?1:0) "\t" $0}' | sort -k1,1n -s | head -1 | cut -f2-)"
  if [ -z "$img" ]; then echo "Não encontrei nenhum fundo com \"$pedido\". Usa: /fundo lista"; exit 1; fi
  caminho="$IMGS/$img"
fi

# 1) grava como fundo padrão do tema (perfil do iTerm2) e no "Claude · Último"
if [ "$img" = "--original" ]; then fundo_definir "$tema" --original; else fundo_definir "$tema" "$caminho"; fi \
  && fundos_gerar && ultimo_guardar "$tema" \
  && guardado=" Ficou como fundo padrão do tema $nome_tema: as abas novas abrem com ele." \
  || guardado=" Não consegui gravá-lo como fundo padrão do tema $nome_tema."

# 2) muda já a aba onde estás
pid=$$; tty=""
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  t="$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')"
  if [ -n "$t" ] && [ "$t" != "??" ]; then tty="$t"; break; fi
  pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
done
if [ -n "$tty" ]; then
  case "$tty" in /dev/*) dev="$tty" ;; *) dev="/dev/$tty" ;; esac
  b64="$(printf %s "$caminho" | base64 | tr -d '\n')"
  printf '\033]1337;SetBackgroundImageFile=%s\a' "$b64" > "$dev"
else
  guardado="$guardado (Não encontrei a aba do iTerm2: abre uma aba nova para veres.)"
fi
case "$img" in
  "")          echo "Fundo removido.$guardado" ;;
  --original)  echo "Voltei ao fundo original do tema: $(basename "$caminho" .png).$guardado" ;;
  *)           echo "Fundo trocado para: ${img%.png}.$guardado" ;;
esac
