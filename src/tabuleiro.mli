(* Operações de tabuleiro: criação, validação e vizinhanças *)
open Types

(* Cria tabuleiro de ataque n x n inicializado a Desconhecido *)
val criar_tabuleiro_ataque : int -> tabuleiro_ataque

(* Cria tabuleiro de defesa n x n inicializado a None *)
val criar_tabuleiro_defesa : int -> tabuleiro_defesa

(* Testa se uma coordenada está dentro dos limites *)
val coordenada_valida : int -> coordenada -> bool

(* Lê o estado de ataque numa coordenada *)
val obter_estado_ataque : tabuleiro_ataque -> coordenada -> estado_ataque

(* Escreve o estado de ataque numa coordenada *)
val definir_estado_ataque : tabuleiro_ataque -> coordenada -> estado_ataque -> unit

(* Devolve vizinhos ortogonais válidos *)
val coordenadas_adjacentes : int -> coordenada -> coordenada list

(* Devolve vizinhos diagonais válidos *)
val coordenadas_diagonais : int -> coordenada -> coordenada list

(* Devolve todos os vizinhos (ortogonais + diagonais) válidos *)
val coordenadas_ao_redor : int -> coordenada -> coordenada list
