#!/bin/bash
# Troca o tema de uma vez: perfil do iTerm2 (fundo e cores) + cores do Claude Code.
# Uso: tema.sh lista | rengoku | lofi | pixel
PASTA="$(cd "$(dirname "$0")" && pwd)"
pedido="$(echo "$*" | tr 'A-Z' 'a-z')"
case "$pedido" in
  ""|lista) echo "Temas disponíveis:"; echo "  rengoku   – brasas e samurai"; echo "  lofi      – Lofi Cidades (Lisboa e cidades inventadas)"; echo "  pixel     – Cidade Pixel com o robozinho"; exit 0 ;;
  *reng*) perfil="Claude · Rengoku"; slug="rengoku"; nome="Rengoku" ;;
  *lofi*) perfil="Claude · Lofi Cidades"; slug="lofi-cidades"; nome="Lofi Cidades" ;;
  *pixel*|*cidade*) perfil="Claude · Cidade Pixel"; slug="cidade-pixel"; nome="Cidade Pixel" ;;
  *) echo "Não conheço o tema \"$*\". Usa: /tema lista"; exit 1 ;;
esac
mkdir -p "$HOME/.claude/themes"
sed "s/\"name\": *\"[^\"]*\"/\"name\": \"Tema ativo · $nome\"/" "$PASTA/claude-code/themes/$slug.json" > "$HOME/.claude/themes/tema-ativo.json"
pid=$$; tty=""
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  t="$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')"
  if [ -n "$t" ] && [ "$t" != "??" ]; then tty="$t"; break; fi
  pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
done
if [ -n "$tty" ]; then
  case "$tty" in /dev/*) dev="$tty" ;; *) dev="/dev/$tty" ;; esac
  printf '\033]1337;SetProfile=%s\a' "$perfil" > "$dev"
  echo "Tema trocado para: $nome (iTerm2 e Claude Code)"
else
  echo "Cores do Claude Code trocadas para $nome, mas não encontrei a janela do iTerm2."
fi
