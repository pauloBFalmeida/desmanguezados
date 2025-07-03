extends Node

func _ready() -> void:
	# ajusta como -1 se nao tiver valor ainda
	for id in Level_id.values():
		if not leveis_highscore.has(id):
			leveis_highscore[id] = -1

# ---- -------------------- ----
# ---- Salvos               ----
# ---- -------------------- ----

# ---- Configuracoes ----
var possivel_aim_all_time : bool = false
var indicador_direcao_transparente_sem_target : bool = true

var volume_musica_menu : float = -20.0
var volume_musica_partida : float = -25.0
var volume_efeitos_partida : float = 0.0

# ---- Scores ----
var leveis_highscore : Dictionary[Level_id, int] = {}

# ---- -------------------- ----
# ---- Nao Salvos           ----
# ---- -------------------- ----

enum Level_id {ZEN, TUTORIAL, TUTORIAL_JOGAR, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5}

enum Medalha_tipo {OURO, PRATA, BRONZE, NENHUMA}

const LEVEIS_NOME : Dictionary[Level_id, String] = {
	Level_id.ZEN: "Zen",
	Level_id.TUTORIAL: "Tutorial 1",
	Level_id.TUTORIAL_JOGAR: "Tutorial 2",
	Level_id.LEVEL_1: "Level 1",
	Level_id.LEVEL_2: "Level 2",
	Level_id.LEVEL_3: "Level 3 Maré",
	Level_id.LEVEL_4: "Level 4",
	Level_id.LEVEL_5: "Level 5",
}

const LEVEIS_SELECAO_ORDEM : Array[Level_id] = [
	Level_id.TUTORIAL,
	Level_id.TUTORIAL_JOGAR,
	Level_id.LEVEL_1,
	Level_id.LEVEL_2,
	Level_id.LEVEL_3,
	Level_id.LEVEL_4,
	Level_id.LEVEL_5,
]

const LEVEIS_IMAGE : Dictionary[Level_id, CompressedTexture2D] = {
	#Level_id.TUTORIAL: preload()
}

## tempo para consquistar as medalhas de cada level
## 		ou seja, tem que conquistar com pelo menos esse tempo de sobra no relogio
##		so vai ganhar ouro de 70s, se terminar com mais de 70 segundos de tempo restante
const LEVEIS_MEDALHAS : Dictionary[Level_id, Dictionary] = {
	Level_id.TUTORIAL: {
		Medalha_tipo.OURO:   70,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 50 
		},
	Level_id.TUTORIAL_JOGAR: {
		Medalha_tipo.OURO:   70,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 50 
		},
	Level_id.LEVEL_1: {
		Medalha_tipo.OURO:   50,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 70
		},
	Level_id.LEVEL_2: {
		Medalha_tipo.OURO:   50,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 70
		},
	Level_id.LEVEL_3: {
		Medalha_tipo.OURO:   50,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 70
		},
	Level_id.LEVEL_4: {
		Medalha_tipo.OURO:   50,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 70
		},
	Level_id.LEVEL_5: {
		Medalha_tipo.OURO:   50,
		Medalha_tipo.PRATA:  60,
		Medalha_tipo.BRONZE: 70
		},
}

func get_medalha_level(level_id : Level_id, tempo : int) -> Medalha_tipo:
	# nao esta na lista de leveis para jogar
	if not LEVEIS_SELECAO_ORDEM.has(level_id): return Medalha_tipo.NENHUMA
	# tempo invalido
	if tempo < 0: return Medalha_tipo.NENHUMA
	
	var medalhas_tempos := LEVEIS_MEDALHAS[level_id]
	
	if tempo >= medalhas_tempos[Medalha_tipo.OURO]:
		return Medalha_tipo.OURO
	elif tempo >= medalhas_tempos[Medalha_tipo.PRATA]:
		return Medalha_tipo.PRATA
	elif tempo >= medalhas_tempos[Medalha_tipo.BRONZE]:
		return Medalha_tipo.BRONZE
	
	return Medalha_tipo.NENHUMA

func score_level(level_id : Level_id, tempo : int) -> void:
	# nao esta na lista de leveis para jogar -> nao faca nada
	if not LEVEIS_SELECAO_ORDEM.has(level_id): return
	
	# novo highscore
	if tempo > leveis_highscore[level_id]:
		leveis_highscore[level_id] = tempo
		SaveManager.save_game()

# ---- Durante a Execucao ----
## jogo ja teve um load feito, i.e., ja foi carregado as Globais
var jogo_ja_loaded : bool = false

# configuracoes do modo zen
var modo_zen_ter_1_jogador : bool = true
var modo_zen_mapa_seed : int = 42
var modo_zen_mapa_size : int = 50
var modo_zen_porcent_pinos  : float = 7.0
var modo_zen_porcent_mangue : float = 1.5
var modo_zen_porcent_lixo   : float = 9.0

var current_level_id : Level_id
