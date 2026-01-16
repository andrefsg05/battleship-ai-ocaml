## Descrição

Desenvolvimento de um agente computacional autónomo, em OCaml, capaz de jogar
Batalha Naval. O agente deve gerir o seu próprio tabuleiro, implementar uma estratégia de ataque inteligente e comunicar com um adversário (ou um script de teste) através de um protocolo de texto (stdin/stdout).

## Estruturas de Dados

- **coordenada**: par `(int * int)` representando `(linha, coluna)`.
- **estado_ataque**: `Desconhecido | Agua | Tiro | Afundado` — estado de cada célula do tabuleiro de ataque.
- **tipo_barco**: `PortaAvioes | Destroyer | Fragata | Torpedeiro | Submarino`.
- **barco**:
  - `nome: string`
  - `tipo: tipo_barco`
  - `posicoes: coordenada list` (lista de coordenadas)
  - `acertos: int (mutable)`
  - `tamanho: int`
  - `afundado: bool (mutable)`
- **tabuleiro_ataque**: `estado_ataque array array` — matriz 2D (array de arrays) com resultados dos disparos.
- **tabuleiro_defesa**: `(barco option) array array` — matriz 2D (array de arrays) com `option` (Some barco | None) por célula.
- **estado_jogo**:
  - `dimensao: int`
  - `tabuleiro_defesa: tabuleiro_defesa` (array 2D)
  - `tabuleiro_ataque: tabuleiro_ataque` (array 2D)
  - `barcos: barco list` (lista de barcos)
  - `turno: bool` — `true` se é a nossa vez.
  - `ultima_posicao_ataque: coordenada option` (Some coord | None)
  - `posicoes_candidatas: coordenada list` (lista de coordenadas)
  - `barco_em_cauda: tipo_barco option` (Some tipo | None)

## Compilar e Executar

Pré-requisitos: OCaml.

Compilar (bytecode):
```bash
make clean && make
```

Executar:
```bash
./batalha_naval < input.txt
```
ou para interação manual:
```bash
./batalha_naval
```


## Estratégia de IA

A estratégia é composta por três etapas, em ordem de prioridade:

- **Modo Destruição** (prioridade alta):
  - Se existirem dois ou mais acertos (`Tiro`) alinhados numa mesma linha ou coluna, o agente continua a atacar nas extremidades desse bloco para completar o afundamento.
  - Implementação: identifica alinhamentos, calcula `min/max` nas direções e tenta as células adjacentes ainda desconhecidas.

- **Modo Caça** (prioridade média):
  - Quando existem acertos isolados, tenta as células adjacentes (cima/baixo/esquerda/direita) ainda `Desconhecido` para descobrir a orientação do barco.

- **Padrão Xadrez** (fallback eficiente):
  - Quando não há informação útil de acertos, o agente prioriza células em padrão xadrez (paridade de `linha+coluna`) para maximizar cobertura com metade dos disparos.

- **Aleatório** (último caso):
  - Se não existir histórico útil, escolhe coordenadas aleatórias `Desconhecido` (com limite de tentativas para evitar loops).

O agente também marca `Agua` em volta de uma célula de acerto que resulta em `Afundado`, seguindo a regra de que barcos não se tocam — isto reduz o espaço de busca e evita tentativas inúteis.


## Exemplos de Uso (protocolo texto)
### Posicionamento Manual
```
init 8
barco porta-aviões 0 0 0 1 0 2 1 2 2 2
barco destroyer 4 4 4 5 4 6 4 7
barco fragata 6 0 6 1 6 2
barco fragata 2 5 3 5 4 5
barco torpedeiro 7 7 7 6
barco torpedeiro 1 7 2 7
barco torpedeiro 5 1 5 0
barco submarino 3 0
vou eu
```

### Posicionamento Aleatório
```
init 8
random
vou eu
```

### Durante o jogo
- O agente ataca enviando: "tiro L C"
- O adversário responde: "água" | "tiro <nome>" | "afundado <nome>" | "perdi"
- Quando o adversário ataca, envia "tiro L C"; o agente responde com uma das strings acima.

## Fluxo do Agente

1) Configuração
  - "init N" define dimensão
  - "barco ..." posiciona manualmente (ou "random" gera frota)
  - "vou eu" ou "vai tu" define quem começa

2) Loop de jogo
  - Se é a nossa vez: escolhe próxima jogada (proxima_jogada), envia "tiro L C", processa resposta
  - Se é a vez do adversário: lê "tiro L C", responde conforme acerto/afundado/água/perdi
  - Alterna turnos até alguém enviar "perdi"

## Âmbito do projeto

Este projeto foi desenvolvido como trabalho académico para a disciplina de Programação III na Universidade de Évora.

## Autores

- André Gonçalves
- [André Zhan](https://github.com/andr-zhan)
