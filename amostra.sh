#!/bin/bash
# Amostra para testar o tema: as 16 cores do terminal, estilos de texto, ícones e exemplos coloridos.
# Funciona no bash do Mac (3.2). Usado pelo comando /tema-teste.
E=$'\033'; R="${E}[0m"
nomes=(preto vermelho verde amarelo azul magenta ciano branco)

echo ""
echo "${E}[1m■ As 16 cores do terminal${R}"
linha1=""; linha2=""
for i in 0 1 2 3 4 5 6 7; do
  linha1="$linha1${E}[4${i}m      ${R} "
  linha2="$linha2${E}[10${i}m      ${R} "
done
echo "  normal  $linha1"
echo "  claro   $linha2"
txt=""; for i in 0 1 2 3 4 5 6 7; do txt="$txt${E}[3${i}m${nomes[$i]}${R} "; done; echo "  texto   $txt"
txt=""; for i in 0 1 2 3 4 5 6 7; do txt="$txt${E}[9${i}m${nomes[$i]}${R} "; done; echo "  claro   $txt"

echo ""
echo "${E}[1m■ Estilos de texto${R}"
echo "  ${E}[1mnegrito${R}  ${E}[2mapagado${R}  ${E}[3mitálico${R}  ${E}[4msublinhado${R}  ${E}[9mriscado${R}  ${E}[7minvertido${R}"

echo ""
echo "${E}[1m■ Gradiente (cores reais)${R}"
g="  "; for i in $(seq 0 47); do r=$((255 - i*5)); gg=$((60 + i*3)); b=$((i*5)); g="$g${E}[48;2;${r};${gg};${b}m ${R}"; done; echo "$g"

echo ""
echo "${E}[1m■ Ícones (precisam de uma Nerd Font)${R}"
echo "   pasta    casa    ramo do git    certo    aviso    erro    música    seta do prompt"

echo ""
echo "${E}[1m■ Como fica um git diff${R}"
echo "  ${E}[1mdiff --git a/player.gd b/player.gd${R}"
echo "  ${E}[36m@@ -40,4 +40,4 @@ func _physics_process(delta):${R}"
echo "       velocity.y += gravity * delta"
echo "  ${E}[31m-    if is_on_floor():${R}"
echo "  ${E}[32m+    if is_on_floor() or coyote > 0:${R}"
echo "           velocity.y = JUMP_SPEED"

echo ""
echo "${E}[1m■ Como fica uma lista de arquivos${R}"
echo "  ${E}[1;34mimagens/${R}  ${E}[1;34mscripts/${R}  ${E}[1;32minstalar.command${R}  README.md  ${E}[35mfundo.png${R}  ${E}[31mbackup.zip${R}"

echo ""
echo "${E}[1m■ Mensagens${R}"
echo "  ${E}[32m✓ 12 testes passaram${R}"
echo "  ${E}[33m! 2 avisos: a textura idle_03.png é muito grande${R}"
echo "  ${E}[31m✗ Erro: não encontrei o arquivo fase2.tscn${R}"
echo "  ${E}[2m  dica: corre de novo com --verbose para ver mais${R}"
echo ""
