extends Node

const SAVE_GAME_PATH = "user://save_game.cfg"

# ----- Acessar o disco -----
func load_game(force_load : bool = true) -> bool:
	# se nao eh para forcar um load, e jogo ja foi carregado -> nao faca nada 
	if (not force_load) and Globais.jogo_ja_loaded: return true
	
	var file = ConfigFile.new()
	if file.load(SAVE_GAME_PATH) != OK:  # se o arquivo nao existe
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
	file.save(SAVE_GAME_PATH)

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
		var tempo : int = file.get_value("highscore", str(level), Globais.no_highscore_value)
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
	file.save(SAVE_GAME_PATH)

func reset_save_partida() -> void:
	# reseta os scores
	for level : LevelManager.Level_id in Globais.leveis_highscore.keys():
		Globais.leveis_highscore[level] = Globais.no_highscore_value
	# save to disk
	save_game()


# ----------------------- Save Input Controls --------------------
const SAVE_INPUT_PATH = "user://save_input.cfg"

# ----- Acessar o disco -----
func reset_inputs() -> void:
	var file = ConfigFile.new()
	file.clear()
	# save to disk
	file.save(SAVE_INPUT_PATH)

func load_todos_inputs() -> void:
	var file = ConfigFile.new()
	if file.load(SAVE_INPUT_PATH) != OK:  # se o arquivo nao existe
		return
	# coloca os valores nas globais
	_ajustar_todos_inputs(file)

## coloca os inputs do arquivo de um jogador
##		retorna true -> se tinha alguma acao para colocar
##		retorna false -> se nao colocou nenhuma acao 
func load_player_input(player : InputManager.PlayerId, on_controle : bool) -> bool:
	var file = ConfigFile.new()
	if file.load(SAVE_INPUT_PATH) != OK:  # se o arquivo nao existe
		return false # retorna que nao conseguiu colocar os valores
	# retorna se colocou alguma acao dos eventos
	return _ler_input_player(file, player, on_controle)

func _ajustar_todos_inputs(file : ConfigFile) -> void:
	for player in InputManager.PlayerId.values():
		var on_controle : bool = InputManager.players_no_controle.has(player)
		_ler_input_player(file, player, on_controle)

func _ler_input_player(file : ConfigFile, player : InputManager.PlayerId, on_controle : bool) -> bool:
	var colocou_alguma_acao : bool = false
	for action : String in InputManager.action_names:
		# criar o section do configFile
		var section : String
		section  = "player_" + str(player+1)
		section += "_c" if on_controle else "_k"
		section += "_" + action
		# pega a quantidade de eventos que tem na acao
		var amount = file.get_value(section, "amount", 0)
		if amount == 0: continue # se nao tem -> pule
		# remove as acoes presentes atuais
		InputManager.remove_actions_input(player, action)
		# load de cada evento
		for count in range(amount):
			# key do configFile
			var key : String = "event_" + str(count)
			# salva o evento
			var data : Dictionary = _load_evento(file, section, key)
			var event : InputEvent = _create_event_from_data(data)
			InputManager.add_action_input(player, action, event)
		# marca que colocou alguma acao
		colocou_alguma_acao = true
	return colocou_alguma_acao

func save_inputs(player : InputManager.PlayerId) -> void:
	var file = ConfigFile.new()
	
	for action : String in InputManager.action_names:
		# criar o section do configFile
		var section : String
		section  = "player_" + str(player+1)
		section += "_c" if InputManager.players_no_controle.has(player) else "_k"
		section += "_" + action
		# pega a lista da eventos de uma acao
		var event_list : Array = InputManager.get_action_events(player, action)
		if event_list.is_empty(): continue # se nao tem eventos na acao -> pule
		# salva a quantidade de eventos que tem na acao
		var amount := event_list.size()
		file.set_value(section, "amount", amount)
		# salva cada evento
		for count in range(amount):
			var event : InputEvent = event_list[count]
			var data : Dictionary  = InputManager.get_event_data(event, player) 
			if data.is_empty(): continue # se nao conseguiu pegar os dados acao -> pule
			# key do configFile
			var key : String = "event_" + str(count)
			# salva o evento
			_salva_evento(file, data, section, key)
	
	# save to disk
	file.save(SAVE_INPUT_PATH)

func _salva_evento(file : ConfigFile, data : Dictionary, 
					section : String, key_original : String) -> void:
	# adiciona _ depois da key original 
	key_original = key_original + "_"
	# salva "no_controle"
	file.set_value(section, key_original + "on_controle", data["on_controle"])
	# -- esta no controle --
	if data["on_controle"]:
		file.set_value(section, key_original + "button", data["button"])
		# se tem 'controle_tipo' -> salva
		if data.has("controle_tipo"):
			file.set_value(section, key_original + "controle_tipo", data["controle_tipo"])
	# -- esta no mouse teclado --
	else:
		file.set_value(section, key_original + "on_mouse", data["on_mouse"])
		if data["on_mouse"]:
			file.set_value(section, key_original + "button", data["button"])
		else: # no teclado
			if data.has("unicode"):
				file.set_value(section, key_original + "unicode", data["unicode"])
			file.set_value(section, key_original + "physical_keycode", data["physical_keycode"])

func _load_evento(file : ConfigFile, section : String, key_original : String) -> Dictionary:
	var data : Dictionary = {}
	# adiciona _ depois da key original
	key_original = key_original + "_"
	
	data["on_controle"] = file.get_value(section, key_original + "on_controle", false)
	# -- esta no controle --
	if data["on_controle"]:
		data["button"] = file.get_value(section, key_original + "button", 0)
		# se tem 'controle_tipo'
		#	# como controle_tipo eh um enum, -1 so eh possivel se get_value nao tiver a key
		var controle_tipo : int = file.get_value(section, key_original + "controle_tipo", -1)
		if controle_tipo != -1: # tem controle_tipo
			data["controle_tipo"] = controle_tipo
	# -- esta no mouse teclado --
	else:
		data["on_mouse"] = file.get_value(section, key_original + "on_mouse", false)
		if data["on_mouse"]:
			data["button"] = file.get_value(section, key_original + "button", 0)
		else: # no teclado
			data["unicode"] = file.get_value(section, key_original + "unicode", 0)
			data["physical_keycode"] = file.get_value(section, key_original + "physical_keycode", 0)
	# retorna a data que montamos
	return data

func _create_event_from_data(data : Dictionary) -> InputEvent:
	# -- no controle --
	if data["on_controle"]:
		if data.has("controle_tipo"):
			var event := InputEventJoypadButton.new()
			# pegue o tipo de controle (PS, Xbox ...)
			var controle_tipo = data["controle_tipo"]
			# nos temos o Controle_btn, mas queremos o index do botao no device (controle)
			#	para isso fazemos o oposto de: btn_indexes[index do device] -> Controle_btn
			#	que eh entao: dado Controle_btn no btn_indexes -pegamos-> index do device
			var btn_indexes = InputManager.controle_btn_indexes[controle_tipo]
			for btn_index in btn_indexes.keys():
				if btn_indexes[btn_index] == data["button"]:
					event.button_index = btn_index
					return event
		else: # nao tem controle_tipo -> entao eh axis
			var event := InputEventJoypadMotion.new()
			match data["button"]:
				InputManager.Controle_btn.LT:
					event.axis = JOY_AXIS_TRIGGER_LEFT
				InputManager.Controle_btn.RT:
					event.axis = JOY_AXIS_TRIGGER_RIGHT
	# -- mouse e teclado --
	else:
		if data["on_mouse"]: # mouse
			var event := InputEventMouseButton.new()
			event.button_index = data["button"]
			return event
		else: # teclado
			var event := InputEventKey.new()
			if data["unicode"] != 0:
				event.unicode = int( data["unicode"] )
			#else: # nao tem unicode -> physical keycode
			event.physical_keycode = data["physical_keycode"]
			return event
	# nao deve cair aqui
	return InputEventJoypadButton.new()
