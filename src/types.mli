(* Assinaturas dos tipos principais do jogo Batalha Naval *)

(* Posição (linha, coluna) no tabuleiro *)
type coordenada = int * int

(* Estado de uma célula no tabuleiro de ataque *)
type estado_ataque =
  | Desconhecido
  | Agua
  | Tiro
  | Afundado

(* Tipos de barco possíveis *)
type tipo_barco =
  | PortaAvioes
  | Destroyer
  | Fragata
  | Torpedeiro
  | Submarino

(* Estrutura que representa um barco *)
type barco = {
  nome: string;
  tipo: tipo_barco;
  posicoes: coordenada list;
  mutable acertos: int;
  tamanho: int;
  mutable afundado: bool;
}

(* Matriz de estados para acompanhar disparos *)
type tabuleiro_ataque = estado_ataque array array

(* Matriz de barcos (ou vazio) para defesa *)
type tabuleiro_defesa = (barco option) array array

(* Estado global do jogo *)
type estado_jogo = {
  mutable dimensao: int;
  mutable tabuleiro_defesa: tabuleiro_defesa;
  mutable tabuleiro_ataque: tabuleiro_ataque;
  mutable barcos: barco list;
  mutable turno: bool;
  mutable ultima_posicao_ataque: coordenada option;
  mutable posicoes_candidatas: coordenada list;
  mutable barco_em_cauda: tipo_barco option;
}

(* Resposta possível a um ataque recebido *)
type resposta_ataque =
  | Agua
  | Tiro of string
  | Afundado of string
  | Perdi

(* Célula do tabuleiro de defesa: barco ou vazio *)
type celula_defesa = barco option
