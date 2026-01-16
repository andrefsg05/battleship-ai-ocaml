(* Módulo principal *)

open Types
open Tabuleiro
open Barco
open Protocolo
open Estrategia


(* -------------------------------------------------------------------------------------------- *)  
(* Inicializa o estado do jogo *)
let criar_estado_inicial () =
  {
    dimensao = 8;
    tabuleiro_defesa = criar_tabuleiro_defesa 8;
    tabuleiro_ataque = criar_tabuleiro_ataque 8;
    barcos = [];
    turno = false;
    ultima_posicao_ataque = None;
    posicoes_candidatas = [];
    barco_em_cauda = None;
  }


(* -------------------------------------------------------------------------------------------- *)  
(* Fase de configuração: lê os comandos de setup 
init N: Define tamanho do tabuleiro
barco nome L1 C1 L2 C2 ...: Posiciona um barco
random: Gera frota aleatória
vou eu: Nós atacamos primeiro
vai tu: Oponente ataca primeiro*)

let rec fase_configuracao estado =
  match ler_linha () with
  | None -> () (* Fim de ficheiro *)
  | Some linha ->
    let trimmed = String.trim linha in
    
    if trimmed = "" then
      fase_configuracao estado
    (* Configuração → definir dimensão do tabuleiro (init N) *)
    else if String.starts_with ~prefix:"init" trimmed then (
      match parse_init_comando trimmed with
      | Some n ->
        estado.dimensao <- n;
        estado.tabuleiro_defesa <- criar_tabuleiro_defesa n;
        estado.tabuleiro_ataque <- criar_tabuleiro_ataque n;
        fase_configuracao estado
      | None -> fase_configuracao estado
    )
    (* Posicionar barco manualmente (barco nome L1 C1 ...) *)
    else if String.starts_with ~prefix:"barco" trimmed then (
      let resto = String.sub trimmed 6 (String.length trimmed - 6) in
      match parse_barco_comando resto with
      | Some (nome, posicoes) ->
        let tipo =
          match String.lowercase_ascii nome with
          | "porta-avioes" | "porta-aviões" -> PortaAvioes
          | "destroyer" -> Destroyer
          | "fragata" -> Fragata
          | "torpedeiro" -> Torpedeiro
          | "submarino" -> Submarino
          | _ -> Torpedeiro
        in
        let novo_barco = criar_barco nome tipo posicoes in
        if barco_valido estado.dimensao novo_barco estado.barcos then
          estado.barcos <- novo_barco :: estado.barcos;
        fase_configuracao estado
      | None -> fase_configuracao estado
    )
    (* Gerar frota aleatória completa *)
    else if trimmed = "random" then (
      estado.barcos <- criar_frota_aleatoria estado.dimensao;
      fase_configuracao estado
    )
    (* Nós atacamos primeiro (nossa vez) *)
    else if trimmed = "vou eu" then (
      estado.turno <- true;
      ()
    )
    (* Adversário ataca primeiro (vez dele) *)
    else if trimmed = "vai tu" then (
      estado.turno <- false;
      ()
    )
    else
      fase_configuracao estado


(* -------------------------------------------------------------------------------------------- *)        
(* Processa um ataque recebido 
1. Verifica se há barco nessa coordenada
2. Se não há barco: retorna Agua
3. Se há barco:
   - Registra acerto (incrementa contador)
   - Se barco está afundado:
     - Se todos afundados: retorna Perdi (perdemos!)
     - Se não: retorna Afundado nome
   - Se ainda há vida: retorna Tiro nome*)

let processa_ataque_recebido estado (l, c) =
  match barco_na_posicao estado.barcos (l, c) with
  | None ->
    Agua
  | Some barco ->
    registar_acerto barco;
    if barco.afundado then
      if todos_afundados estado.barcos then
        Perdi
      else
        Afundado barco.nome
    else
      Tiro barco.nome


(* -------------------------------------------------------------------------------------------- *)        
(* Fase de jogo: turnos alternados 
Quando é nossa vez:
1. Calcula próxima coordenada a atacar
2. Envia comando `tiro L C`
3. Lê resposta (água, tiro, afundado, perdi)
4. Processa resposta
5. Se não perdemos (ganhámos), termina
6. Se não ganhámos, passa turno ao oponente

Quando é vez do oponente:
1. Lê comando `tiro L C`
2. Processa ataque (verifica barcos)
3. Envia resposta (água, tiro, afundado, perdi)
4. Se não perdemos, passa turno
5. Se perdemos, termina*)

let rec fase_jogo estado =
  if estado.turno then (
    (* Nossa vez de atacar *)
    let coord = proxima_jogada estado in
    escrever_resposta (formata_ataque coord);
    
    (* Aguarda resposta *)
    match ler_linha () with
    | None -> ()
    | Some linha ->
      (match parse_resposta_ataque linha with
      | Some resposta ->
        processa_resposta_ataque estado coord resposta;
        (match resposta with
        | Perdi -> () (* Vencemos! *)
        | _ -> 
          estado.turno <- false;
          fase_jogo estado)
      | None -> fase_jogo estado)
  ) else (
    (* Vez do adversário atacar *)
    match ler_linha () with
    | None -> ()
    | Some linha ->
      (match parse_tiro_comando linha with
      | Some (l, c) ->
        let resposta = processa_ataque_recebido estado (l, c) in
        escrever_resposta (formata_resposta_defesa resposta);
        (match resposta with
        | Perdi -> () (* Perdemos *)
        | _ ->
          estado.turno <- true;
          fase_jogo estado)
      | None -> fase_jogo estado)
  )


(* -------------------------------------------------------------------------------------------- *)    
(* Ponto de entrada principal *)
let () =
  Random.self_init ();
  
  let estado = criar_estado_inicial () in
  
  (* Executa fase de configuração *)
  fase_configuracao estado;
  
  (* Executa fase de jogo *)
  fase_jogo estado
