extends Node

const SAVE_PATH = "user://save_game.cfg"

# ----- Acessar o disco -----
func load_game(force_load : bool = true) -> bool:
	# se nao eh para forcar um load, e jogo ja foi carregado -> nao faca nada 
	if (not force_load) and Globais.jogo_ja_loaded: return true
	
	var file = ConfigFile.new()
	if file.load(SAVE_PATH) != OK:  # se o arquivo nao existe
		return false
	# coloca os valores nas globais
	_ajustar_globais(file)
	return true

func save_game() -> void:
	var file = ConfigFile.new()
	# --- Configuracoes ---
	# - Controles -
	for player in InputManager.PlayerId.values():
		file.set_value("controle", "tipo_"+str(player), Globais.controle_tipo_player[player])
	# - Gameplay -
	file.set_value("config", "possivel_aim_all_time", Globais.possivel_aim_all_time)
	file.set_value("config", "indicador_direcao_transparente_sem_target", Globais.indicador_direcao_transparente_sem_target)
	# - Audio -
	file.set_value("config", "volume_musica_menu", Globais.volume_musica_menu)
	file.set_value("config", "volume_musica_partida", Globais.volume_musica_partida)
	file.set_value("config", "volume_efeitos_partida", Globais.volume_efeitos_partida)
	# - Exibicao -
	file.set_value("config", "tela_cheia", Globais.tela_cheia)
	file.set_value("config", "remov_efeitos_graf", Globais.remov_efeitos_graf)
	file.set_value("config", "remov_logo_intro", Globais.remov_logo_intro)
	# --- HighScore das partidas ---
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		var tempo : int = Globais.leveis_highscore[level]
		file.set_value("highscore", str(level), tempo)
	# --- Estatisticas ---
	file.set_value("stats", "stats_arvores_plantadas", Globais.stats_arvores_plantadas)
	file.set_value("stats", "stats_arvores_pinos_cortadas", Globais.stats_arvores_pinos_cortadas)
	file.set_value("stats", "stats_lixos_coletados", Globais.stats_lixos_coletados)
	file.set_value("stats", "stats_ferramentas_pegas", Globais.stats_ferramentas_pegas)
	file.set_value("stats", "stats_ferramentas_jogadas", Globais.stats_ferramentas_jogadas)
	file.set_value("stats", "stats_zen_tiles_competamente_jogados", Globais.stats_zen_tiles_competamente_jogados)
	
	# save to disk
	file.save(SAVE_PATH)

# ----- Ajustar as globais -----
# coloca valores do arquivo nas nos globais
func _ajustar_globais(file : ConfigFile) -> void:
	Globais.jogo_ja_loaded = true # salva que ja tem um load feito
	# --- Configuracoes ---
	# - Controles -
	for player in InputManager.PlayerId.values():
		var tipo : int = file.get_value("controle", "tipo_"+str(player), 0)
	# - Gameplay -
	Globais.possivel_aim_all_time = file.get_value("config", "possivel_aim_all_time", false)
	Globais.indicador_direcao_transparente_sem_target = file.get_value("config", "indicador_direcao_transparente_sem_target", true)
	# - Audio -
	Globais.volume_musica_menu     = file.get_value("config", "volume_musica_menu", -20.0)
	Globais.volume_musica_partida  = file.get_value("config", "volume_musica_partida", -25.0)
	Globais.volume_efeitos_partida = file.get_value("config", "volume_efeitos_partida", 0.0)
	# - Exibicao -
	Globais.tela_cheia         = file.get_value("config", "tela_cheia", true)
	Globais.remov_efeitos_graf = file.get_value("config", "remov_efeitos_graf", false)
	Globais.remov_logo_intro   = file.get_value("config", "remov_logo_intro", false)
	# --- HighScore das partidas ---
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		var tempo : int = file.get_value("highscore", str(level), -1)
		Globais.leveis_highscore[level] = tempo
	# --- Estatisticas ---
	Globais.stats_arvores_plantadas      = file.get_value("stats", "stats_arvores_plantadas", 0)
	Globais.stats_arvores_pinos_cortadas = file.get_value("stats", "stats_arvores_pinos_cortadas", 0)
	Globais.stats_lixos_coletados        = file.get_value("stats", "stats_lixos_coletados", 0)
	Globais.stats_ferramentas_pegas      = file.get_value("stats", "stats_ferramentas_pegas", 0)
	Globais.stats_ferramentas_jogadas    = file.get_value("stats", "stats_ferramentas_jogadas", 0)
	Globais.stats_zen_tiles_competamente_jogados = file.get_value("stats", "stats_zen_tiles_competamente_jogados", 0)
	
	#print('Globais.possivel_aim_all_time ', Globais.possivel_aim_all_time)
	#print('Globais.indicador_direcao_transparente_sem_target ', Globais.indicador_direcao_transparente_sem_target)
	#print('Globais.leveis_highscore ', Globais.leveis_highscore)

# ----- Reset Globais das config -----
func reset_globais_config() -> void:
	# - Controles -
	for player in InputManager.PlayerId.values():
		Globais.controle_tipo_player[player] = InputManager.Controle_tipo.values()[0]
	# - Gameplay -
	Globais.possivel_aim_all_time = false
	Globais.indicador_direcao_transparente_sem_target = true
	# - Audio -
	Globais.volume_musica_menu     = -20.0
	Globais.volume_musica_partida  = -25.0
	Globais.volume_efeitos_partida = 0.0
	# - Exibicao -
	Globais.tela_cheia         = true
	Globais.remov_efeitos_graf = false
	Globais.remov_logo_intro   = false
	

# ----- Delete Save -----
func reset_save() -> void:
	var file = ConfigFile.new()
	file.clear()
	# re load
	_ajustar_globais(file)
	# save to disk
	file.save(SAVE_PATH)

func reset_save_partida() -> void:
	# reseta os scores
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		Globais.leveis_highscore[level] = -1
	# save to disk
	save_game()
