extends Node

# quando comparamos o score pegamos o menor
#	-entao-> usamos um valor alto para os leveis sem highscore ainda
const no_highscore_value : int = 999

func _ready() -> void:
	# ajusta o valor dos que leveis sem highscore ainda 
	for id in LevelManager.Level_id.values():
		if not leveis_highscore.has(id):
			leveis_highscore[id] = Globais.no_highscore_value
	# ajusta a tela cheia
	ajustar_tela_cheia()

func is_abrindo_jogo() -> bool:
	# jogo nao estava aberto -> abriu agora
	if not is_jogo_aberto:
		is_jogo_aberto = true
		# retorne true -> que esta abrindo agora
		return true
	# retorne false -> que ja estava aberto
	return false

# ---- -------------------- ----
# ---- Salvos               ----
# ---- -------------------- ----

# ---- Configuracoes ----
var possivel_aim_all_time : bool = false
var indicador_direcao_transparente_sem_target : bool = true

var controle_tipo_player : Dictionary[InputManager.PlayerId, InputManager.Controle_tipo]={
	InputManager.PlayerId.P1 : InputManager.Controle_tipo.PS, 
	InputManager.PlayerId.P2 : InputManager.Controle_tipo.PS }

var volume_musica_menu : float = -20.0
var volume_musica_partida : float = -25.0
var volume_efeitos_partida : float = 0.0

var tela_cheia := false
var remov_efeitos_graf := false
var remov_logo_intro := false

# ---- Scores ----
var leveis_highscore : Dictionary[LevelManager.Level_id, int] = {}

# ---- Estatisticas ----
var stats_arvores_plantadas = 0
var stats_arvores_pinos_cortadas = 0
var stats_lixos_coletados = 0
var stats_ferramentas_pegas = 0
var stats_ferramentas_jogadas = 0
var stats_zen_tiles_competamente_jogados = 0

# ---- Durante a Execucao ----
var is_jogo_aberto := false

## jogo ja teve um load feito, i.e., ja foi carregado as Globais
var jogo_ja_loaded : bool = false

# configuracoes do modo zen
var modo_zen_ter_1_jogador : bool = true
var modo_zen_mapa_seed : int = 42
var modo_zen_mapa_size : int = 50
var modo_zen_porcent_pinos  : float = 7.0
var modo_zen_porcent_mangue : float = 1.5
var modo_zen_porcent_lixo   : float = 9.0

var current_level_id : LevelManager.Level_id = LevelManager.LEVEIS_SELECAO_ORDEM[0]

func ajustar_tela_cheia() -> void:
	# true -> full screen
	if tela_cheia:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# false -> janela
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 

func verif_rem_efeito(nodo : Node2D) -> void:
	# se nao for para remover os efeitos graficos -> nao faca nada
	if not remov_efeitos_graf: return
	
	print(nodo)
	nodo.material = CanvasItemMaterial.new()
