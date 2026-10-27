---
description: Mostra uma amostra de tudo para testar o tema (cores do terminal, ícones, diff, tarefas, textos)
allowed-tools: Bash(bash "__PASTA__/amostra.sh":*)
---
Estou a testar o tema visual do terminal. Faz estes passos por esta ordem, sem perguntas e sem comentários entre eles:

1. Corre `bash "__PASTA__/amostra.sh"` com a ferramenta Bash. Mostra as 16 cores do terminal, estilos de texto, ícones e exemplos coloridos.

2. Cria o arquivo `/tmp/tema-teste/Jogador.java` com exatamente este conteúdo:

```java
public class Jogador {
    private int vida = 100;
    private boolean noChao = true;

    public void pular() {
        if (noChao) {
            System.out.println("Pulou!");
        }
    }
}
```

3. Edita esse arquivo numa só alteração: troca `if (noChao) {` por `if (noChao || coyoteTime > 0) {` e acrescenta a linha `    private double coyoteTime = 0.1;` logo abaixo de `private boolean noChao = true;`. Assim aparecem linhas novas, linhas apagadas e palavras mudadas.

4. Se tiveres uma ferramenta de lista de tarefas, cria estas três: "Ver as cores do terminal" (concluída), "Ver o diff do código" (em curso) e "Escolher o tema preferido" (por fazer).

5. Por fim, responde só com este texto, tal como está:

# Título grande
## Título médio
### Título pequeno

Texto normal com **negrito**, *itálico*, `código no meio do texto` e um [link](https://github.com/joaocalixto/temas-claude-code).

- Primeiro item
- Segundo item, com `um_comando --opcao`
  - Item dentro de outro

1. Passo um
2. Passo dois

> Uma citação: é aqui que se vê a cor do texto mais apagado.

| Tema | Cor do Claude | Fundo |
|---|---|---|
| Rengoku | laranja | brasas |
| Lofi Cidades | coral | cidades |
| Cidade Pixel | ciano | pixel art |

```bash
# um bloco de código
for t in rengoku lofi pixel; do echo "tema: $t"; done
```

Esta é uma linha comprida de propósito, para ver como o texto quebra quando passa da largura da janela, sem nenhuma pontuação pelo meio para não dar pausa nenhuma até ao fim.

---

Para trocar de tema: `/tema lofi` · `/tema pixel` · `/tema rengoku`
