(* Protocolo de I/O: leitura, parse e formatação de comandos/respostas *)
open Types

(* Lê uma linha do stdin (Some linha | None) *)
val ler_linha : unit -> string option

(* Escreve uma resposta no stdout e faz flush *)
val escrever_resposta : string -> unit

(* Interpreta "init N" devolvendo N se válido *)
val parse_init_comando : string -> int option

(* Interpreta linha de posicionamento de barco, devolvendo nome e coordenadas *)
val parse_barco_comando : string -> (string * coordenada list) option

(* Interpreta comando "tiro L C" *)
val parse_tiro_comando : string -> coordenada option

(* Interpreta resposta a ataque: água/tiro/afundado/perdi *)
val parse_resposta_ataque : string -> resposta_ataque option

(* Formata resposta de defesa para string *)
val formata_resposta_defesa : resposta_ataque -> string

(* Formata comando de ataque "tiro L C" *)
val formata_ataque : coordenada -> string
