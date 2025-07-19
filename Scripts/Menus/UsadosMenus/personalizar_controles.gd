extends Control

@export var primeiro_botao : Button
@onready var waiting_input := $ColorRectWaitingInput
@onready var waiting_input_button := $ColorRectWaitingInput/Button
@onready var grid := $ScrollContainerPersControles/GridContainer

@onready var btns_pegar : Array[Button] = [
	$ScrollContainerPersControles/GridContainer/ButtonFerPegar, 
	$ScrollContainerPersControles/GridContainer/ButtonFerPegar2 ]
@onready var btns_largar : Array[Button] = [
	$ScrollContainerPersControles/GridContainer/ButtonFerLargar,
	$ScrollContainerPersControles/GridContainer/ButtonFerLargar2 ]
@onready var btns_usar : Array[Button] = [
	$ScrollContainerPersControles/GridContainer/ButtonFerUsar, 
	$ScrollContainerPersControles/GridContainer/ButtonFerUsar2 ]
@onready var btns_jogar_forca : Array[Button] = [
	$ScrollContainerPersControles/GridContainer/ButtonFerJogarForca, 
	$ScrollContainerPersControles/GridContainer/ButtonFerJogarForca2 ]

signal input_apertado

var controle_player_curr : InputManager.PlayerId
var escutar_input : bool = false
var event_input : InputEvent
var event_data_input : Dictionary

func _ready() -> void:
	waiting_input.hide()
	# funciona durante o pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func mostrar_personalizar_controle(
			_controle_player_curr : InputManager.PlayerId,
			botao_tag : Button
			) -> void:
	controle_player_curr = _controle_player_curr
	# foco no primeiro botao
	primeiro_botao.grab_focus()
	# ajusta todos os neighbors left para serem o botao da tag 'controles'
	for item in grid.get_children():
		# item eh um botao AND esta na 2 coluna
		if item is Button and (item.get_index() % grid.columns == 1):
			item.focus_neighbor_left = botao_tag.get_path()
	
	# -- ajusta o texto dos botoes --
	_ajustar_texto_botao_acao(btns_pegar, "pickup")
	_ajustar_texto_botao_acao(btns_largar, "drop")
	_ajustar_texto_botao_acao(btns_usar, "interact")
	_ajustar_texto_botao_acao(btns_jogar_forca, "throw_force")

# ----------- Ouvir inputs ----------
func _input(event):
	if not escutar_input: return
	
	var data = _get_event_data(event)
	if not data.is_empty():
		event_input = event
		event_data_input = data
		emit_signal("input_apertado")

func _get_event_data(event : InputEvent) -> Dictionary:
	var data := {}
	if event is InputEventJoypadButton:
		var controle_tipo = Globais.controle_tipo_player[controle_player_curr]
		var btn_index = InputManager.controle_btn_indexes[controle_tipo]
		var id = event.button_index
		if btn_index.has(id):
			data["button"] = btn_index[id]
			data["on_controle"] = true
			return data
	elif event is InputEventJoypadMotion:
		# se for LT ou RT (trigger) garante que tenha apertado um pouco
		#	para evitar apertos acidentais ou deadzones 
		if escutar_input and event.axis_value < 0.4: return data
		# se nao estiver escutando por inputs, ou passar do threshold
		if event.axis == JOY_AXIS_TRIGGER_LEFT:
			data["button"] = InputManager.Controle_btn.LT
			data["on_controle"] = true
			return data
		elif event.axis == JOY_AXIS_TRIGGER_RIGHT:
			data["button"] = InputManager.Controle_btn.RT
			data["on_controle"] = true
			return data
	elif event is InputEventKey:
		data["on_controle"] = false
		return data
	return data

# ----------- Ouvir inputs ----------
func _receber_input() -> void:
	# mostro o pop-up 
	waiting_input.show()
	waiting_input_button.grab_focus()
	get_tree().paused = true
	# comeca a escutar
	escutar_input = true
	
	# esperar ate ter input
	await input_apertado
	
	# para de escutar
	escutar_input = false
	# escondo o pop up e volto ao normal
	waiting_input.hide()
	await get_tree().process_frame
	get_tree().paused = false
	await get_tree().process_frame

func _alterar_input(event_name : String, botao : Button) -> void:
	# botao ja tinha uma acao antes -> mude para a nova acao
	if botao.get_meta("contem_acao", false):
		InputManager.change_controller_action(
			controle_player_curr, 	# player id do controle
			event_name, 			# nome da acao no InputManager.action_names
			event_input				# event novo que vamos colocar na acao
		)
	# botao nao tinha uma acao antes -> adicione a nova acao
	else:
		InputManager.add_controller_action(
			controle_player_curr, 	# player id do controle
			event_name, 			# nome da acao no InputManager.action_names
			event_input				# event novo que vamos colocar na acao
		)

# ----------- Ajustar Botoes ----------
func _ajustar_texto_botao_acao(btns : Array[Button], action : String) -> void:
	# para cada botao da acao -> associe um event da acao do input manager
	var action_events : Array[InputEvent] = InputManager.get_action_events(controle_player_curr, action)
	for contador in range(len(btns)):
		var botao : Button = btns[contador]
		var data : Dictionary = {}
		
		# se passou a quantidade de eventos -> proximo 
		if contador >= len(action_events):
			botao.set_meta("contem_acao", false)
			_alterar_texto_botao(botao, InputManager.Controle_btn.NONE)
			continue
			
		var evento : InputEvent = action_events[contador]
		data = _get_event_data(evento)
		
		# nao tem dados de evento -ou seja-> nao tem evento associado -> proximo
		if data.is_empty():
			botao.set_meta("contem_acao", false)
			_alterar_texto_botao(botao, InputManager.Controle_btn.NONE)
			continue
		
		# coloca que o botao contem uma acao
		botao.set_meta("contem_acao", true)
		# -- analisa a acao --
		# se for no controle -> altere o texto do button para o botao controle 
		if data["on_controle"]:
			_alterar_texto_botao(botao, data["button"])
		# se for no teclado -> altere o texto do button para o botao do keyboard
		else:
			botao.text = _get_string_keyboard(evento)

func _ajustar_texto_botao_evento(button : Button) -> void:
	if event_data_input["on_controle"]:
		var controle_button := InputManager.Controle_btn.NONE
		controle_button = event_data_input["button"]
		# ajustar texto
		_alterar_texto_botao(button, controle_button)
	else:
		button.text = _get_string_keyboard(event_input)

func _alterar_texto_botao(button: Button, controle_button: InputManager.Controle_btn) -> void:
	# caso seja invalido
	if controle_button == InputManager.Controle_btn.NONE:
		button.text = '-'
		button.grab_focus() # pega o foco
		return
	
	# tipo de controle (PS, Xbox ...)
	var controle_tipo = Globais.controle_tipo_player[controle_player_curr]
	# pega a String que representa o botao
	var btn_nomes = InputManager.controle_btn_nomes[controle_tipo]
	# ajustar o texto
	button.text = btn_nomes[controle_button]
	# pega o foco
	button.grab_focus()

func _get_string_keyboard(event : InputEventKey) -> String:
	if event.unicode != 0:
		return char(event.unicode)
	else:
		var keycode := DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		return OS.get_keycode_string(keycode)

# ---------------------------------------------------- Pegar
func _on_button_fer_pegar_pressed() -> void:
	await _receber_input()
	_alterar_input("pickup", btns_pegar[0])
	_ajustar_texto_botao_evento(btns_pegar[0])

func _on_button_fer_pegar2_pressed() -> void:
	await _receber_input()
	_alterar_input("pickup", btns_pegar[1])
	_ajustar_texto_botao_evento(btns_pegar[1])

# ---------------------------------------------------- Largar
func _on_button_fer_largar_pressed() -> void:
	await _receber_input()
	_alterar_input("drop", btns_largar[0])
	_ajustar_texto_botao_evento(btns_largar[0])

func _on_button_fer_largar2_pressed() -> void:
	await _receber_input()
	_alterar_input("drop", btns_largar[1])
	_ajustar_texto_botao_evento(btns_largar[1])

# ---------------------------------------------------- Usar
func _on_button_fer_usar_pressed() -> void:
	await _receber_input()
	_alterar_input("interact", btns_usar[0])
	_ajustar_texto_botao_evento(btns_usar[0])

func _on_button_fer_usar2_pressed() -> void:
	await _receber_input()
	_alterar_input("interact", btns_usar[1])
	_ajustar_texto_botao_evento(btns_usar[1])

# ---------------------------------------------------- Jogar Forca 
func _on_button_fer_jogar_forca_pressed() -> void:
	await _receber_input()
	_alterar_input("throw_force", btns_jogar_forca[0])
	_ajustar_texto_botao_evento(btns_jogar_forca[0])

func _on_button_fer_jogar_forca_2_pressed() -> void:
	await _receber_input()
	_alterar_input("throw_force", btns_jogar_forca[1])
	_ajustar_texto_botao_evento(btns_jogar_forca[1])
