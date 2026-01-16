(* Tipos e estruturas de dados para o jogo de Batalha Naval *)

(* -------------------------------------------------------------------------------------------- *)
(* Coordenadas do tabuleiro *)
type coordenada = int * int


(* -------------------------------------------------------------------------------------------- *)
(* Estados de uma célula no tabuleiro de ataque *)
type estado_ataque =
  | Desconhecido  (* Célula não disparada *)
  | Agua          (* Disparo resultou em água *)
  | Tiro          (* Acerto, barco ainda não afundado *)
  | Afundado      (* Acerto, barco já afundado *)


(* -------------------------------------------------------------------------------------------- *)  
(* Tipos de barcos disponíveis *)
type tipo_barco =
  | PortaAvioes   (* 5 células, forma de T *)
  | Destroyer     (* 4 células, linear *)
  | Fragata       (* 3 células, linear *)
  | Torpedeiro    (* 2 células, linear *)
  | Submarino     (* 1 célula *)


(* -------------------------------------------------------------------------------------------- *)
(* Informação sobre um barco *)
type barco = {
  nome: string;                    (* Nome do barco (ex: "porta-aviões", "destroyer") *)
  tipo: tipo_barco;                (* Tipo do barco *)
  posicoes: coordenada list;       (* Lista de coordenadas ocupadas *)
  mutable acertos: int;            (* Número de acertos neste barco *)
  tamanho: int;                    (* Tamanho total do barco *)
  mutable afundado: bool;          (* Se o barco está afundado *)
}


(* -------------------------------------------------------------------------------------------- *)
(* Tabuleiro: matriz de estados *)
type tabuleiro_ataque = estado_ataque array array


(* -------------------------------------------------------------------------------------------- *)
(* Tabuleiro de defesa: matriz de coordenadas dos barcos ou vazio *)
type tabuleiro_defesa = (barco option) array array


(* -------------------------------------------------------------------------------------------- *)
(* Estado do jogo *)
type estado_jogo = {
  mutable dimensao: int;                             (* Dimensão do tabuleiro (N x N) *)
  mutable tabuleiro_defesa: tabuleiro_defesa;        (* Nossos barcos *)
  mutable tabuleiro_ataque: tabuleiro_ataque;        (* Conhecimento dos ataques *)
  mutable barcos: barco list;                        (* Lista de nossos barcos *)
  mutable turno: bool;                               (* true = nossa vez de atacar *)
  mutable ultima_posicao_ataque: coordenada option;  (* Última posição atacada ou vazio*)
  mutable posicoes_candidatas: coordenada list;      (* Posições para caça *)
  mutable barco_em_cauda: tipo_barco option;         (* Barco em modo caça ou vazio *)
}


(* -------------------------------------------------------------------------------------------- *)
(* Resposta a um ataque *)
type resposta_ataque =
  | Agua
  | Tiro of string    (* Nome do barco acertado *)
  | Afundado of string (* Nome do barco afundado *)
  | Perdi


(* -------------------------------------------------------------------------------------------- *)
(* Para tabuleiro de defesa, usamos option para representar barco ou nada *)
type celula_defesa = barco option
