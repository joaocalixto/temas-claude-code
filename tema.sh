#!/bin/bash
# Troca o tema de uma vez: perfil do iTerm2 (fundo, cores, letra) + tema do Claude Code.
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

# 1) Claude Code: garante o arquivo do tema e escolhe-o em ~/.claude/settings.json ("theme": "custom:<slug>").
#    O Claude Code relê esse arquivo sozinho, por isso muda na hora.
mkdir -p "$HOME/.claude/themes"
[ -f "$HOME/.claude/themes/$slug.json" ] || cp "$PASTA/claude-code/themes/$slug.json" "$HOME/.claude/themes/"
cc="não mudei o tema do Claude Code (falta o osascript)"
if command -v osascript >/dev/null 2>&1; then
  if TEMA="custom:$slug" ARQ="$HOME/.claude/settings.json" osascript -l JavaScript >/dev/null 2>&1 <<'JS'
ObjC.import('Foundation');
var env = $.NSProcessInfo.processInfo.environment;
var arq = env.objectForKey('ARQ').js, tema = env.objectForKey('TEMA').js;
var texto = '{}';
if ($.NSFileManager.defaultManager.fileExistsAtPath(arq)) {
  var lido = ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(arq, $.NSUTF8StringEncoding, null));
  if (typeof lido === 'string') texto = lido;
}
var cfg = JSON.parse(texto.trim() === '' ? '{}' : texto);   // se o arquivo estiver estragado, pára aqui sem escrever
cfg.theme = tema;
if (!$(JSON.stringify(cfg, null, 2) + '\n').writeToFileAtomicallyEncodingError(arq, true, $.NSUTF8StringEncoding, null)) throw new Error('sem escrita');
JS
  then cc="Claude Code"; else cc="não consegui mudar o tema do Claude Code (escreve /theme e escolhe $nome)"; fi
fi

# 2) iTerm2: muda o perfil desta janela
pid=$$; tty=""
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  t="$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')"
  if [ -n "$t" ] && [ "$t" != "??" ]; then tty="$t"; break; fi
  pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')"
done
if [ -n "$tty" ]; then
  case "$tty" in /dev/*) dev="$tty" ;; *) dev="/dev/$tty" ;; esac
  printf '\033]1337;SetProfile=%s\a' "$perfil" > "$dev"
  echo "Tema trocado para: $nome (iTerm2 e $cc)"
else
  echo "Tema trocado para: $nome ($cc). Não encontrei a janela do iTerm2."
fi
