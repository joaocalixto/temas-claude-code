#!/bin/bash
# Instala os 3 temas (Rengoku, Lofi Cidades, Cidade Pixel) no iTerm2 e no Claude Code,
# mais os comandos /tema e /fundo. Pode correr de novo sempre que quiseres atualizar.
set -e
PASTA="$(cd "$(dirname "$0")" && pwd)"
ITERM="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

if [ ! -d "/Applications/iTerm.app" ] && [ ! -d "$HOME/Applications/iTerm.app" ]; then
  echo "  Aviso: não encontrei o iTerm2. Instala-o em https://iterm2.com e corre isto de novo."
fi

mkdir -p "$ITERM" "$HOME/.claude/themes" "$HOME/.claude/commands"

# fonte JetBrains Mono Nerd Font (com os ícones do prompt), só se ainda não existir
mkdir -p "$HOME/Library/Fonts"
for f in "$PASTA"/fonte/*.ttf; do
  [ -f "$HOME/Library/Fonts/$(basename "$f")" ] || cp "$f" "$HOME/Library/Fonts/"
done
rm -f "$ITERM/claude-cidade-pixel.json"   # nome antigo
sed "s#__PASTA__#$PASTA#g" "$PASTA/iterm2/temas-claude-code.json" > "$ITERM/claude-temas.json"
cp "$PASTA"/claude-code/themes/*.json "$HOME/.claude/themes/"

# perfil "Claude · Último": guarda o último /tema e /fundo, para as abas novas abrirem igual
. "$PASTA/lembrar.sh"
[ -f "$ULTIMO_ARQ" ] || ultimo_guardar "$(ultimo_tema)"
# põe-no como perfil padrão do iTerm2. Só dá com o iTerm2 fechado: aberto, ele guarda o padrão antigo por cima.
if pgrep -x iTerm2 >/dev/null 2>&1; then
  padrao="  3. Uma vez só: iTerm2 > Settings > Profiles > \"$ULTIMO_NOME\" > Other Actions… > Set as Default
     Assim as abas e janelas novas abrem com o último tema e fundo que escolheste."
else
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$ULTIMO_GUID"
  padrao="  3. O perfil \"$ULTIMO_NOME\" ficou como padrão do iTerm2: as abas e janelas novas
     abrem com o último tema e fundo que escolheste."
fi
for c in fundo tema tema-teste; do
  sed "s#__PASTA__#$PASTA#g" "$PASTA/claude-code/commands/$c.md" > "$HOME/.claude/commands/$c.md"
done
chmod +x "$PASTA/fundo.sh" "$PASTA/tema.sh" "$PASTA/amostra.sh"

echo ""
echo "  Pronto! Temas e comandos /tema e /fundo instalados."
echo ""
echo "  1. iTerm2: fecha e abre o iTerm2 (para ele ver a letra nova)"
echo "  2. Claude Code: fecha e abre de novo e escreve /tema pixel (ou lofi, ou rengoku)"
echo "     O /tema muda o iTerm2 e o Claude Code ao mesmo tempo. Para só o fundo: /fundo lista"
echo "     Para ver tudo o que o tema pinta: /tema-teste"
echo "$padrao"
echo ""
echo "  Não apagues nem mudes esta pasta de lugar: os fundos são lidos daqui."
echo "  Se a mudares, corre o instalar.command outra vez."
echo ""
