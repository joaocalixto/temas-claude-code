#!/bin/bash
# Remove os temas, os perfis do iTerm2 e os comandos /tema e /fundo.
ITERM="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
rm -f "$ITERM/claude-temas.json" "$ITERM/claude-cidade-pixel.json" "$ITERM/claude-ultimo.json"
rm -f "$HOME/.claude/themes/"{rengoku,lofi-cidades,cidade-pixel,tema-ativo}.json
rm -f "$HOME/.claude/commands/"{tema,fundo,tema-teste}.md "$HOME/.claude/temas-fundos.txt"
rm -rf "$HOME/.claude/.tema-por-aba"
# se o Claude Code estava num destes temas, volta ao tema escuro normal
if command -v osascript >/dev/null 2>&1 && [ -f "$HOME/.claude/settings.json" ]; then
  ARQ="$HOME/.claude/settings.json" osascript -l JavaScript >/dev/null 2>&1 <<'JS'
ObjC.import('Foundation');
var arq = $.NSProcessInfo.processInfo.environment.objectForKey('ARQ').js;
var cfg = JSON.parse(ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(arq, $.NSUTF8StringEncoding, null)));
if (/^custom:(rengoku|lofi-cidades|cidade-pixel|tema-ativo)$/.test(cfg.theme || '')) {
  cfg.theme = 'dark';
  $(JSON.stringify(cfg, null, 2) + '\n').writeToFileAtomicallyEncodingError(arq, true, $.NSUTF8StringEncoding, null);
}
JS
fi
echo ""
echo "  Pronto, tudo removido."
echo "  O Claude Code voltou ao tema escuro normal (podes escolher outro em /theme)."
echo "  No iTerm2, se um perfil \"Claude · ...\" era o padrão, escolhe outro em Settings > Profiles."
echo ""
