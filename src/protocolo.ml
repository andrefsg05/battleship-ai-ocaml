(* Módulo para protocolo de comunicação *)

open Types


(* -------------------------------------------------------------------------------------------- *)  
(* Lê uma linha do stdin 
Retorno:
- Some linha - linha lida com sucesso
- None - fim do ficheiro*)
let ler_linha () =
  try
    Some (input_line stdin)
  with End_of_file ->
    None

  
(* -------------------------------------------------------------------------------------------- *)  
(* Escreve uma resposta no stdout*)

let escrever_resposta str =
  Printf.printf "%s\n" str;
  flush stdout

 
(* -------------------------------------------------------------------------------------------- *)    
(* Interpreta um comando de configuração 
Exemplo:
Input: init 10
Output: Some 10
Validações:
Deve ter exatamente 2 palavras
N deve ser um inteiro positivo*)

let parse_init_comando linha =
  match String.split_on_char ' ' linha with
  | "init" :: n_str :: [] ->
    (try
      let n = int_of_string n_str in
      if n > 0 then Some n else None
    with _ -> None)
  | _ -> None


(* -------------------------------------------------------------------------------------------- *)    
(* Interpreta um comando de posicionamento de barco 
Exemplo:
Input: porta-aviões 0 0 0 1 0 2 1 2 2 2
Output: Some ("porta-aviões", [(0,0); (0,1); (0,2); (1,2); (2,2)])
Algoritmo:
1. Primeira palavra = nome do barco
2. Resto das palavras agrupadas em pares = coordenadas
3. Coordenadas em base 0 (0-7)*)

let parse_barco_comando linha =
  match String.split_on_char ' ' linha with
  | nome :: resto ->
    (* Agrupa em pares (L, C) *)
    let rec agrupa_pares = function
      | [] -> []
      | [_] -> [] 
      | l_str :: c_str :: tl ->
        (try
          let l = int_of_string l_str in
          let c = int_of_string c_str in

          (l, c) :: agrupa_pares tl
        with _ -> [])
    in
    let posicoes = agrupa_pares resto in
    if List.length posicoes > 0 then
      Some (nome, posicoes)
    else
      None
  | _ -> None


(* -------------------------------------------------------------------------------------------- *)    
(* Interpreta um comando de ataque recebido 
Exemplo:
Input: tiro 3 5
Output: Some (3, 5) - coordenadas em base 0*)

let parse_tiro_comando linha =
  match String.split_on_char ' ' linha with
  | "tiro" :: l_str :: c_str :: [] ->
    (try
      let l = int_of_string l_str in
      let c = int_of_string c_str in
      (* Coordenadas já em base 0 (0-7) *)
      Some (l, c)
    with _ -> None)
  | _ -> None


(* -------------------------------------------------------------------------------------------- *)    
(* Interpreta a resposta a um ataque 
Exemplos:
Input: água → Output: Some Agua
Input: tiro porta-aviões → Output: Some (Tiro "porta-aviões")
Input: afundado destroyer → Output: Some (Afundado "destroyer")
Input: perdi → Output: Some Perdi*)

let parse_resposta_ataque linha =
  let trimmed = String.trim linha in
  if trimmed = "água" then
    Some Agua
  else if trimmed = "perdi" then
    Some Perdi
  else
    match String.split_on_char ' ' trimmed with
    | "tiro" :: nome_partes ->
      let nome = String.concat " " nome_partes in
      Some (Tiro nome)
    | "afundado" :: nome_partes ->
      let nome = String.concat " " nome_partes in
      Some (Afundado nome)
    | _ -> None


(* -------------------------------------------------------------------------------------------- *)      
(* Formata uma resposta de defesa *)

let formata_resposta_defesa = function
  | Agua -> "água"
  | Tiro nome -> Printf.sprintf "tiro %s" nome
  | Afundado nome -> Printf.sprintf "afundado %s" nome
  | Perdi -> "perdi"


(* -------------------------------------------------------------------------------------------- *)    
(* Formata um comando de ataque 
Exemplo:
Input: (2, 4) - base 0
Output: tiro 2 4 - base 0*)

let formata_ataque (l, c) =
  (* Coordenadas em base 0 (0-7) *)
  Printf.sprintf "tiro %d %d" l c
