extends Node

func _ready() -> void:
	# ajusta como -1 se nao tiver valor ainda
	for id in LevelManager.Level_id.values():
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
var leveis_highscore : Dictionary[LevelManager.Level_id, int] = {}

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

var current_level_id : LevelManager.Level_id
