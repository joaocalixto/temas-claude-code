#!/bin/bash
# Remove os temas, os perfis do iTerm2 e os comandos /tema e /fundo.
ITERM="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
rm -f "$ITERM/claude-temas.json" "$ITERM/claude-cidade-pixel.json"
rm -f "$HOME/.claude/themes/"{rengoku,lofi-cidades,cidade-pixel,tema-ativo}.json
rm -f "$HOME/.claude/commands/"{tema,fundo}.md
echo ""
echo "  Pronto, tudo removido."
echo "  No Claude Code, escreve /theme e escolhe outro tema (por exemplo Dark)."
echo "  No iTerm2, se um perfil \"Claude · ...\" era o padrão, escolhe outro em Settings > Profiles."
echo ""
