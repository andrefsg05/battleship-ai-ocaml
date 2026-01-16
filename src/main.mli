open Types

(* Cria o estado inicial (tabuleiros 8x8 e sem barcos) *)
val criar_estado_inicial : unit -> estado_jogo

(* Lê comandos de configuração (init, barco, random, vou eu/vai tu) e atualiza o estado *)
val fase_configuracao : estado_jogo -> unit

(* Processa um tiro recebido e devolve a resposta apropriada *)
val processa_ataque_recebido : estado_jogo -> coordenada -> resposta_ataque

(* Loop principal de jogo alternando turnos até terminar *)
val fase_jogo : estado_jogo -> unit
