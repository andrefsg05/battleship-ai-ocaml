(* Módulo para posicionamento e gestão de barcos *)

open Types
open Tabuleiro

(* Cria um barco com as coordenadas especificadas *)
let criar_barco nome tipo posicoes =
  let tamanho = List.length posicoes in
  {
    nome = nome;
    tipo = tipo;
    posicoes = posicoes;
    acertos = 0;
    tamanho = tamanho;
    afundado = false;
  }
(* -------------------------------------------------------------------------------------------- *)
(* Verifica se duas posições estão adjacentes (nao em diagonal) *)
let adjacentes (l1, c1) (l2, c2) =
  (abs (l1 - l2) = 1 && c1 = c2) || (abs (c1 - c2) = 1 && l1 = l2)


(* -------------------------------------------------------------------------------------------- *)
(* Verifica se um barco é linear
Como funciona:
1. Verifica se cada par consecutivo de posições é adjacente
2. Se algum par não é adjacente, retorna false
3. Listas vazias ou com 1 elemento são consideradas lineares *)

let eh_linear posicoes =
  match posicoes with
  | [] | [_] -> true
  | hd :: tl ->
    let rec verifica_alinhamento = function
      | [] -> true
      | [_] -> true
      | p1 :: p2 :: resto ->
        if adjacentes p1 p2 then
          verifica_alinhamento (p2 :: resto)
        else
          false
    in
    verifica_alinhamento posicoes


(* -------------------------------------------------------------------------------------------- *)
(* Valida se um barco está bem posicionado
Verificações:
1. Coordenadas válidas: Todas as posições estão dentro do tabuleiro n×n
2. Sem sobreposição: Nenhuma célula já é ocupada por outro barco
3. Sem adjacência: Nenhum barco pode estar ao lado (nem em diagonal) de outro*)

let barco_valido n barco barcos_existentes =
  let posicoes = barco.posicoes in
  
  (* Verifica se todas as coordenadas são válidas *)
  let coords_validas = List.for_all (fun coord -> coordenada_valida n coord) posicoes in
  
  if not coords_validas then false
  else
    (* Verifica se não há sobreposição com outros barcos *)
    let sem_sobreposicao = 
      List.for_all (fun pos ->
        not (List.exists (fun outro ->
          List.mem pos outro.posicoes
        ) barcos_existentes)
      ) posicoes
    in
    
    if not sem_sobreposicao then false
    else
      (* Verifica se não há barcos adjacentes (nem diagonais) *)
      let sem_adjacencia =
        List.for_all (fun pos ->
          let ao_redor = coordenadas_ao_redor n pos in
          not (List.exists (fun volta ->
            List.exists (fun outro ->
              List.mem volta outro.posicoes
            ) barcos_existentes
          ) ao_redor)
        ) posicoes
      in
      sem_adjacencia


(* -------------------------------------------------------------------------------------------- *)
(* Porta-aviões em forma de T 
Parâmetros:
- `(l, c)`: Coordenada central (a base da T)
- `orient`: Direção para a qual o T aponta
Exemplos de saída:
- Orientação `Up`: T aponta para cima 
    |
    |
  - - -
- Orientação `Right`: T aponta para a direita
  |
  |- - -
  |
  *)

let gerar_porta_avioes (l, c) orient =
  match orient with
  | `Up -> [ (l, c - 1); (l, c); (l, c + 1); (l - 1, c); (l - 2, c) ]
  | `Down -> [ (l, c - 1); (l, c); (l, c + 1); (l + 1, c); (l + 2, c) ]
  | `Left -> [ (l - 1, c); (l, c); (l + 1, c); (l, c - 1); (l, c - 2) ]
  | `Right -> [ (l - 1, c); (l, c); (l + 1, c); (l, c + 1); (l, c + 2) ]


(* -------------------------------------------------------------------------------------------- *)
(* Gera uma frota completa em posiçoes aleatórias 
Algoritmo:
1. Tenta colocar cada tipo de barco em posição aleatória
2. Se não conseguir colocar (sobreposição ou fora do tabuleiro), tenta outra posição
3. Limita a 500 tentativas por barco para evitar loop infinito
4. Recursivamente preenche a frota até ter 8 barcos*)

let criar_frota_aleatoria n =
  let random_coord () = (Random.int n, Random.int n) in
  let random_direcao () = Random.bool () in
  let random_orient_t () = match Random.int 4 with 0 -> `Up | 1 -> `Right | 2 -> `Down | _ -> `Left in

  (* Gera posições lineares 
  Se o tamanho for 1, devolve só a posição.
  Se for maior, usa List.init para criar os pontos seguintes.
  Se direcao for true, soma à coluna (Horizontal).
  Se direcao for false, soma à linha (Vertical).*)
  let rec gera_posicoes_lineares pos tamanho direcao =
    if tamanho = 1 then [ pos ]
    else
      let (l, c) = pos in
      let proximas =
        if direcao then List.init (tamanho - 1) (fun i -> (l, c + i + 1))
        else List.init (tamanho - 1) (fun i -> (l + i + 1, c))
      in
      pos :: proximas
  in

  
  (* Tenta posicionar
  Processo:
  Escolhe uma coordenada e orientação aleatória.
  Calcula as posições ocupadas (seja em "T" ou Linear).
  Cria o objeto barco (criar_barco).
  Validação (barco_valido):
    - Sucesso: Se o barco cabe e não bate em ninguém, adiciona-o à lista barcos_criados.
    - Falha: Chama-se a si mesma (tenta_posicionar) mas com tentativas - 1.
  Se as tentativas chegarem a 0, a função devolve a lista sem este novo barco (falhou).*)

  let rec tenta_posicionar forma nome tamanho tentativas barcos_criados =
    if tentativas <= 0 then barcos_criados
    else
      let pos = random_coord () in
      let posicoes =
        match forma with
        | `T -> gerar_porta_avioes pos (random_orient_t ())
        | `Lin dir -> gera_posicoes_lineares pos tamanho dir
      in
      let tipo =
        match nome with
        | "porta-aviões" -> PortaAvioes
        | "destroyer" -> Destroyer
        | "fragata" -> Fragata
        | "torpedeiro" -> Torpedeiro
        | _ -> Submarino
      in
      let novo_barco = criar_barco nome tipo posicoes in
      if barco_valido n novo_barco barcos_criados then novo_barco :: barcos_criados
      else tenta_posicionar forma nome tamanho (tentativas - 1) barcos_criados
  in


  (* Controla a criação de todos os barcos*)
  let rec completa_frota barcos =
    if List.length barcos = 8 then barcos
    else
      let b =
        barcos
        |> tenta_posicionar `T "porta-aviões" 5 500
        |> tenta_posicionar (`Lin (random_direcao ())) "destroyer" 4 500
        |> tenta_posicionar (`Lin (random_direcao ())) "fragata" 3 500
        |> tenta_posicionar (`Lin (random_direcao ())) "fragata" 3 500
        |> tenta_posicionar (`Lin (random_direcao ())) "torpedeiro" 2 500
        |> tenta_posicionar (`Lin (random_direcao ())) "torpedeiro" 2 500
        |> tenta_posicionar (`Lin (random_direcao ())) "torpedeiro" 2 500
        |> tenta_posicionar (`Lin (random_direcao ())) "submarino" 1 500
      in
      if List.length b = 8 then b else completa_frota []   (* Se a lista criada nao tiver 8 barcos, limpa a lista e tenta novamente.*)
  in

  completa_frota []


(* -------------------------------------------------------------------------------------------- *)
(* Encontra o barco em uma coordenada específica 
Uso: Quando o inimigo dispara, usamos isto para saber se acertou num barco.*)
let barco_na_posicao barcos (l, c) =
  List.find_opt (fun barco ->
    List.mem (l, c) barco.posicoes
  ) barcos


(* -------------------------------------------------------------------------------------------- *)
(* Registra um acerto em um barco 
Incrementa o contador de acertos e marca como afundado se necessário.*)
let registar_acerto barco =
  barco.acertos <- barco.acertos + 1;
  if barco.acertos >= barco.tamanho then
    barco.afundado <- true


(* -------------------------------------------------------------------------------------------- *)    
(* Obtém todos os barcos afundados *)
let barcos_afundados barcos =
  List.filter (fun barco -> barco.afundado) barcos


(* -------------------------------------------------------------------------------------------- *)
(* Verifica se todos os barcos foram afundados 
Retorna true se toda a frota foi destruída (perdemos)*)
let todos_afundados barcos =
  List.length (barcos_afundados barcos) = List.length barcos
