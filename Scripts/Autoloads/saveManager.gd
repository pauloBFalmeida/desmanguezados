extends Node

const SAVE_PATH = "user://save_game.cfg"

# ----- Acessar o disco -----
func load_game(force_load : bool = true) -> bool:
	# se nao eh para forcar um load, e jogo ja foi carregado -> nao faca nada 
	if (not force_load) and Globais.jogo_ja_loaded: return true
	
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:  # se o arquivo nao existe
		return false
	# coloca os valores nas globais
	_ajustar_globais(config)
	return true

func save_game() -> void:
	var config = ConfigFile.new()
	# --- Configuracoes ---
	# - Gameplay -
	config.set_value("config", "possivel_aim_all_time", Globais.possivel_aim_all_time)
	config.set_value("config", "indicador_direcao_transparente_sem_target", Globais.indicador_direcao_transparente_sem_target)
	# - Audio -
	config.set_value("config", "volume_musica_menu", Globais.volume_musica_menu)
	config.set_value("config", "volume_musica_partida", Globais.volume_musica_partida)
	config.set_value("config", "volume_efeitos_partida", Globais.volume_efeitos_partida)
	# --- HighScore das partidas ---
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		var tempo : int = Globais.leveis_highscore[level]
		config.set_value("highscore", str(level), tempo)
	
	# save to disk
	config.save(SAVE_PATH)

# ----- Ajustar as globais -----
# coloca valores do arquivo nas nos globais
func _ajustar_globais(config : ConfigFile) -> void:
	Globais.jogo_ja_loaded = true # salva que ja tem um load feito
	# --- Configuracoes ---
	# - Gameplay -
	Globais.possivel_aim_all_time = config.get_value("config", "possivel_aim_all_time", false)
	Globais.indicador_direcao_transparente_sem_target = config.get_value("config", "indicador_direcao_transparente_sem_target", true)
	# - Audio -
	Globais.volume_musica_menu     = config.get_value("config", "volume_musica_menu", -20.0)
	Globais.volume_musica_partida  = config.get_value("config", "volume_musica_partida", -25.0)
	Globais.volume_efeitos_partida = config.get_value("config", "volume_efeitos_partida", 0.0)
	# --- HighScore das partidas ---
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		var tempo : int = config.get_value("highscore", str(level), -1)
		Globais.leveis_highscore[level] = tempo
	
	print('Globais.possivel_aim_all_time ', Globais.possivel_aim_all_time)
	print('Globais.indicador_direcao_transparente_sem_target ', Globais.indicador_direcao_transparente_sem_target)
	print('Globais.leveis_highscore ', Globais.leveis_highscore)

# ----- Delete Save -----
func reset_save() -> void:
	var config = ConfigFile.new()
	config.clear()
	# re load
	_ajustar_globais(config)
	# save to disk
	config.save(SAVE_PATH)

func reset_save_partida() -> void:
	# reseta os scores
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		Globais.leveis_highscore[level] = -1
	# save to disk
	save_game()
