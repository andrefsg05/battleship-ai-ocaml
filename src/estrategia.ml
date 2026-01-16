(* Módulo para estratégia de ataque (Caça e Destruição) *)

open Types
open Tabuleiro


(* -------------------------------------------------------------------------------------------- *)
(* Auxiliar *)  
let coord_valida estado coord = coordenada_valida estado.dimensao coord


(* -------------------------------------------------------------------------------------------- *)  
(* Auxiliar - Verifica se coordenada já foi atingida *) 
let is_hit estado coord =
  coord_valida estado coord &&
  match obter_estado_ataque estado.tabuleiro_ataque coord with
  | Tiro -> true
  | _ -> false


(* -------------------------------------------------------------------------------------------- *)    
(* Auxiliar - Verifica se coordenada é desconhecida *) 
let unknown estado coord =
  coord_valida estado coord &&
  obter_estado_ataque estado.tabuleiro_ataque coord = Desconhecido


(* -------------------------------------------------------------------------------------------- *)    
(* Modo Caça: Quando há acertos isolados (não alinhados), ataca adjacentes
Se não sabemos a orientação do barco, tentamos em volta do acerto.
1. Encontra todas as células com `Tiro` (acertos não afundados)
2. Para cada acerto, expande para as 4 células adjacentes
3. Filtra para manter apenas células desconhecidas (nunca disparadas)
4. Retorna lista de alvos potenciais*)

let modo_caca estado =
  let n = estado.dimensao in
  
  (* Gerar todas as coordenadas do tabuleiro [(0,0); (0,1); ... (9,9)] *)
  let todas_as_coordenadas =
    List.init n (fun l ->
      List.init n (fun c -> (l, c))
    )
    |> List.flatten 
  in

  (* Filtrar apenas aquelas onde já acertámos (hits) *)
  let hits = List.filter (is_hit estado) todas_as_coordenadas in

  (* O resto da lógica continua igual *)
  hits
  |> List.concat_map (fun coord -> coordenadas_adjacentes n coord)
  |> List.filter (unknown estado)


(* -------------------------------------------------------------------------------------------- *)    
(* Modo Destruição: Se existirem dois ou mais acertos alinhados, continua na linha/coluna 
1. Encontra todos os acertos
2. Verifica se estão alinhados horizontalmente (mesma linha) ou verticalmente (mesma coluna)
3. Se alinhados na linha l:
   - Encontra a coluna mínima e máxima dos acertos
   - Dispara à esquerda (min_c - 1) e à direita (max_c + 1)
4. Se alinhados na coluna c:
   - Encontra a linha mínima e máxima dos acertos
   - Dispara acima (min_l - 1) e abaixo (max_l + 1)*)

let modo_destruicao estado =
  let hits =
    let acc = ref [] in
    for l = 0 to estado.dimensao - 1 do
      for c = 0 to estado.dimensao - 1 do
        if is_hit estado (l, c) then acc := (l, c) :: !acc
      done
    done;
    !acc
  in
  let has_aligned_row =
    hits
    |> List.sort_uniq compare
    |> List.fold_left (fun acc (l, c) ->
         if acc <> None then acc
         else
           let same_row = List.filter (fun (l2, _) -> l2 = l) hits in
           if List.length same_row >= 2 then Some l else None) None
  in
  let has_aligned_col =
    hits
    |> List.sort_uniq compare
    |> List.fold_left (fun acc (_, c) ->
         if acc <> None then acc
         else
           let same_col = List.filter (fun (_, c2) -> c2 = c) hits in
           if List.length same_col >= 2 then Some c else None) None
  in
  match (has_aligned_row, has_aligned_col) with
  | Some l, _ ->
      (* Extender à esquerda e direita do bloco de acertos nessa linha *)
      let cols_hit = hits |> List.filter (fun (lr, _) -> lr = l) |> List.map snd in
      let min_c = List.fold_left min max_int cols_hit in
      let max_c = List.fold_left max min_int cols_hit in
        let left = (l, min_c - 1) in
        let right = (l, max_c + 1) in
        [ left; right ] |> List.filter (unknown estado)
  | _, Some c ->
      (* Extender acima e abaixo do bloco de acertos nessa coluna *)
      let rows_hit = hits |> List.filter (fun (_, cc) -> cc = c) |> List.map fst in
      let min_l = List.fold_left min max_int rows_hit in
      let max_l = List.fold_left max min_int rows_hit in
        let up = (min_l - 1, c) in
        let down = (max_l + 1, c) in
        [ up; down ] |> List.filter (unknown estado)
  | _ -> []


(* -------------------------------------------------------------------------------------------- *)    
(* Padrão de Xadrez: Retorna todas as coordenadas desconhecidas em padrão xadrez
Como barcos ocupam múltiplas células adjacentes, usar padrão xadrez (soma L+C par)
garante detecção de todos os barcos usando apenas metade dos disparos *)

let coordenadas_xadrez estado =
  let n = estado.dimensao in
  let coords = ref [] in
  for l = 0 to n - 1 do
    for c = 0 to n - 1 do
      (* Padrão de xadrez: soma de linha+coluna é par *)
      if (l + c) mod 2 = 0 && unknown estado (l, c) then
        coords := (l, c) :: !coords
    done
  done;
  !coords


(* -------------------------------------------------------------------------------------------- *)    
(* Estratégia: tenta modo destruição, depois modo caça, depois padrão xadrez
Ordem de Prioridade:
1. Modo Destruição: Se há 2+ acertos alinhados, continua nessa linha/coluna
2. Modo Caça: Se há acertos isolados, testa os adjacentes
3. Padrão Xadrez: Ataca células em padrão xadrez para máxima eficiência
4. Aleatório: Último recurso se xadrez estiver esgotado*)

let proxima_jogada estado =
  let destr = modo_destruicao estado in
  if destr <> [] then List.hd destr
  else
    let caca = modo_caca estado in
    if caca <> [] then List.hd caca
    else
      (* Tentar padrão xadrez primeiro *)
      let xadrez = coordenadas_xadrez estado in
      if xadrez <> [] then List.hd xadrez
      else
        (* Só aleatório se xadrez estiver esgotado *)
        let rec encontra_desconhecido tentativas =
          if tentativas <= 0 then (0, 0)
          else
            let coord = (Random.int estado.dimensao, Random.int estado.dimensao) in
            if unknown estado coord then coord else encontra_desconhecido (tentativas - 1)
        in
        encontra_desconhecido 200


(* -------------------------------------------------------------------------------------------- *)        
(* Marca água em volta de um acerto afundado (regra de não tocar) *)
let marcar_adjacentes_como_agua estado coord =
  let around = coordenadas_ao_redor estado.dimensao coord in
  List.iter (fun pos ->
    if unknown estado pos then definir_estado_ataque estado.tabuleiro_ataque pos Agua) around


(* -------------------------------------------------------------------------------------------- *)        
(* Atualiza o estado após receber resposta de um ataque 
1. Converte resposta para estado_ataque
2. Atualiza o tabuleiro
3. Se foi afundado, marca adjacentes como água
4. Guarda a última posição atacada*)
let processa_resposta_ataque estado coordenada resposta =
  let estado_cell : estado_ataque =
    match resposta with
    | Agua -> Agua
    | Types.Tiro _ -> (Tiro : estado_ataque)
    | Types.Afundado _ -> Afundado
    | Perdi -> Desconhecido
  in
  definir_estado_ataque estado.tabuleiro_ataque coordenada estado_cell;
  (match resposta with
   | Afundado _ -> marcar_adjacentes_como_agua estado coordenada
   | _ -> ());
  estado.ultima_posicao_ataque <- Some coordenada
