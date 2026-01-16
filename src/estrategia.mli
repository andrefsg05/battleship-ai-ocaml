(* Estratégia de ataque: caça, destruição e atualização de estado *)
open Types

(* Verifica se uma coordenada está dentro do tabuleiro do estado *)
val coord_valida : estado_jogo -> coordenada -> bool

(* Diz se já há um acerto (Tiro) nesta coordenada *)
val is_hit : estado_jogo -> coordenada -> bool

(* Diz se a coordenada ainda é Desconhecido no tabuleiro de ataque *)
val unknown : estado_jogo -> coordenada -> bool

(* Modo Caça: devolve adjacentes desconhecidos a acertos isolados *)
val modo_caca : estado_jogo -> coordenada list

(* Modo Destruição: devolve prolongamentos em linha/coluna de acertos alinhados *)
val modo_destruicao : estado_jogo -> coordenada list

(* Seleciona a próxima jogada seguindo destruição → caça → aleatório *)
val proxima_jogada : estado_jogo -> coordenada

(* Após afundar, marca água à volta para não voltar a tentar ali *)
val marcar_adjacentes_como_agua : estado_jogo -> coordenada -> unit

(* Atualiza tabuleiro de ataque com a resposta recebida a um tiro *)
val processa_resposta_ataque : estado_jogo -> coordenada -> resposta_ataque -> unit
