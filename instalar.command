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
for c in fundo tema tema-teste; do
  sed "s#__PASTA__#$PASTA#g" "$PASTA/claude-code/commands/$c.md" > "$HOME/.claude/commands/$c.md"
done
chmod +x "$PASTA/fundo.sh" "$PASTA/tema.sh" "$PASTA/amostra.sh"

echo ""
echo "  Pronto! Temas e comandos /tema e /fundo instalados."
echo ""
echo "  1. iTerm2: fecha e abre o iTerm2 (para ele ver a letra nova) e escolhe um perfil \"Claude · ...\" no menu Profiles"
echo "  2. Claude Code: fecha e abre de novo e escreve /tema pixel (ou lofi, ou rengoku)"
echo "     O /tema muda o iTerm2 e o Claude Code ao mesmo tempo. Para só o fundo: /fundo lista"
echo "     Para ver tudo o que o tema pinta: /tema-teste"
echo ""
echo "  Não apagues nem mudes esta pasta de lugar: os fundos são lidos daqui."
echo "  Se a mudares, corre o instalar.command outra vez."
echo ""
