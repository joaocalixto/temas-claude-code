#!/bin/bash
# Troca a imagem de fundo da janela do iTerm2 onde o Claude Code está aberto.
# Uso: fundo.sh lista | aleatorio | nenhum | <parte do nome, ex.: "lisboa 2">
PASTA="$(cd "$(dirname "$0")" && pwd)"
IMGS="$PASTA/imagens"
pedido="$*"
lista() { find "$IMGS" -name '*.png' | sed "s#^$IMGS/##" | sort; }
if [ -z "$pedido" ] || [ "$pedido" = "lista" ]; then
  echo "Fundos disponíveis:"; lista | sed 's/\.png$//; s/^/  /'; exit 0
fi
if [ "$pedido" = "aleatorio" ] || [ "$pedido" = "aleatório" ]; then
  img="$(lista | awk 'BEGIN{srand()} {a[NR]=$0} END{print a[int(rand()*NR)+1]}')"
elif [ "$pedido" = "nenhum" ] || [ "$pedido" = "tirar" ]; then
  img=""
else
  padrao="$(echo "$pedido" | tr 'A-Z' 'a-z' | sed 's/[[:space:]]\{1,\}/.*/g')"
  # prefere a imagem original; as versões "-escura" e "-robo" só quando pedidas
  img="$(lista | grep -i -- "$padrao" | awk '{print ((index($0,"-escura")||index($0,"-robo"))?1:0) "\t" $0}' | sort -k1,1n -s | head -1 | cut -f2-)"
  if [ -z "$img" ]; then echo "Não encontrei nenhum fundo com \"$pedido\". Usa: /fundo lista"; exit 1; fi
fi
pid=$$; tty=""
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  t="$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')"
  if [ -n "$t" ] && [ "$t" != "??" ]; then tty="$t"; break; fi
  pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
done
if [ -z "$tty" ]; then echo "Não encontrei a janela do iTerm2."; exit 1; fi
case "$tty" in /dev/*) dev="$tty" ;; *) dev="/dev/$tty" ;; esac
if [ -n "$img" ]; then b64="$(printf %s "$IMGS/$img" | base64 | tr -d '\n')"; else b64=""; fi
printf '\033]1337;SetBackgroundImageFile=%s\a' "$b64" > "$dev"
if [ -n "$img" ]; then echo "Fundo trocado para: ${img%.png}"; else echo "Fundo removido."; fi
