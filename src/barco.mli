(* Gestão de barcos: criação, validação e consulta de estado *)
open Types

(* Constrói um barco com nome/tipo/posições *)
val criar_barco : string -> tipo_barco -> coordenada list -> barco

(* Verifica se duas coordenadas são adjacentes ortogonalmente *)
val adjacentes : coordenada -> coordenada -> bool

(* Diz se uma lista de posições é linear *)
val eh_linear : coordenada list -> bool

(* Valida se um barco cabe e não colide/encosta a outros *)
val barco_valido : int -> barco -> barco list -> bool

(* Gera as posições do porta-aviões em T na orientação dada *)
val gerar_porta_avioes : coordenada -> [ `Up | `Down | `Left | `Right ] -> coordenada list

(* Cria frota completa aleatória *)
val criar_frota_aleatoria : int -> barco list

(* Procura qual barco ocupa uma coordenada *)
val barco_na_posicao : barco list -> coordenada -> barco option

(* Regista um acerto num barco, podendo marcá-lo afundado *)
val registar_acerto : barco -> unit

(* Lista barcos afundados *)
val barcos_afundados : barco list -> barco list

(* Retorna true se todos os barcos estão afundados *)
val todos_afundados : barco list -> bool
