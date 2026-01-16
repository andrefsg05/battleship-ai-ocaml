(* Módulo para gestão de tabuleiros *)

open Types

(* -------------------------------------------------------------------------------------------- *)
(* Inicializa um tabuleiro de ataque vazio 
(dimensão n x n) 
valor Inicial: Desconhecido*)
let criar_tabuleiro_ataque n =
  Array.make_matrix n n Desconhecido


(* -------------------------------------------------------------------------------------------- *)  
(* Inicializa um tabuleiro de defesa vazio
(dimensão n x n) 
valor Inicial: None*)
let criar_tabuleiro_defesa n =
  Array.make_matrix n n None


(* -------------------------------------------------------------------------------------------- *)  
(* Valida se uma coordenada está dentro dos limites do tabuleiro n x n*)
let coordenada_valida n (l, c) =
  l >= 0 && l < n && c >= 0 && c < n


(* -------------------------------------------------------------------------------------------- *)  
(* Obtém o estado de uma célula no tabuleiro de ataque *)
let obter_estado_ataque tabuleiro (l, c) =
  tabuleiro.(l).(c)


(* -------------------------------------------------------------------------------------------- *)  
(* Define o estado de uma célula no tabuleiro de ataque *)
let definir_estado_ataque tabuleiro (l, c) estado =
  tabuleiro.(l).(c) <- estado


(* -------------------------------------------------------------------------------------------- *)  
(* Obtém as coordenadas adjacentes (sem diagonais) *)
let coordenadas_adjacentes n (l, c) =
  let adjacentes = [
    (l - 1, c);  (* acima *)
    (l + 1, c);  (* abaixo *)
    (l, c - 1);  (* esquerda *)
    (l, c + 1);  (* direita *)
  ] in
  List.filter (fun coord -> coordenada_valida n coord) adjacentes


(* -------------------------------------------------------------------------------------------- *)  
(* Obtém as coordenadas diagonais *)
let coordenadas_diagonais n (l, c) =
  let diagonais = [
    (l - 1, c - 1);
    (l - 1, c + 1);
    (l + 1, c - 1);
    (l + 1, c + 1);
  ] in
  List.filter (fun coord -> coordenada_valida n coord) diagonais


(* -------------------------------------------------------------------------------------------- *)  
(* Obtém todas as coordenadas ao redor (adjacentes + diagonais) *)
let coordenadas_ao_redor n coord =
  (coordenadas_adjacentes n coord) @ (coordenadas_diagonais n coord)