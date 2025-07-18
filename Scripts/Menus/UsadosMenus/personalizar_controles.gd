extends ScrollContainer

@onready var waiting_input := $"../../ColorRectWaitingInput"
@onready var waiting_input_button := $"../../ColorRectWaitingInput"/Button
@onready var grid := $GridContainer
@export var primeiro_botao : Button

@onready var btns_pegar : Array[Button] = [
	$GridContainer/ButtonFerPegar, $GridContainer/ButtonFerPegar2 ]
@onready var btns_largar : Array[Button] = [
	$GridContainer/ButtonFerLargar, $GridContainer/ButtonFerLargar2 ]
@onready var btns_usar : Array[Button] = [
	$GridContainer/ButtonFerUsar, $GridContainer/ButtonFerUsar2 ]

signal input_apertado

var controle_player_curr : InputManager.PlayerId
var escutar_input : bool = false
var event_do_input : InputEvent

func _ready() -> void:
	waiting_input.hide()

# ----------- Ouvir inputs ----------
func _input(event):
	if not escutar_input: return
			
	if event is InputEventJoypadButton:
		if event.pressed:
			event_do_input = event
			emit_signal("input_apertado")
			#print("Button index: %s pressed on device %s" % [event.button_index, event.device])
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_TRIGGER_LEFT and event.axis_value > 0.4:
			event_do_input = event
			emit_signal("input_apertado")
			#print("L2 (gatilho esquerdo): ", event.axis_value)
		elif event.axis == JOY_AXIS_TRIGGER_RIGHT and event.axis_value > 0.4:
			event_do_input = event
			emit_signal("input_apertado")
			#print("R2 (gatilho direito): ", event.axis_value)

#func _get_event_data(event : InputEvent) -> Dictionary:
	

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
	

func _ajustar_texto_botao_acao(btns : Array[Button], action : String) -> void:
	#var e : InputEvent
	
	for evento : InputEvent in InputManager.get_action_events(controle_player_curr, action):
		#evento.
		print(evento.button_index)
		pass

func _receber_input(event_name : String) -> void:
	waiting_input.show()
	waiting_input_button.grab_focus()
	# comeca a escutar
	escutar_input = true
	# esperar ate ter input
	await input_apertado
	InputManager.change_controller_action(
		controle_player_curr, 	# player id do controle
		event_name, 			# nome da acao no InputManager.action_names
		event_do_input			# event novo que vamos colocar na acao
	)
	# para de escutar
	escutar_input = false
	waiting_input.hide()

func _ajustar_texto_botao_evento(button : Button) -> void:
	var controle_btn := InputManager.Controle_btn.A
	# se for um trigger -> eh so pegar direto o botao do controle
	if event_do_input is InputEventJoypadMotion:
		if event_do_input.axis == JOY_AXIS_TRIGGER_LEFT:
			controle_btn = InputManager.Controle_btn.LT
		elif event_do_input.axis == JOY_AXIS_TRIGGER_RIGHT:
			controle_btn = InputManager.Controle_btn.RT
	# se for um botao -> pegar o botao com base no 'index do botao no controle'
	var controle_tipo = Globais.controle_tipo_player[controle_player_curr]
	var btn_index = InputManager.controle_btn_indexes[controle_tipo]
	if event_do_input is InputEventJoypadButton:
		var id = event_do_input.button_index
		if btn_index.has(id):
			controle_btn = btn_index[id]
	# ajustar texto
	_alterar_texto_botao(button, controle_btn)

func _alterar_texto_botao(button: Button, controle_btn: InputManager.Controle_btn) -> void:
	# tipo de controle (PS, Xbox ...)
	var controle_tipo = Globais.controle_tipo_player[controle_player_curr]
	# pega a String que representa o botao
	var btn_nomes = InputManager.controle_btn_nomes[controle_tipo]
	# ajustar o texto
	button.text = btn_nomes[controle_btn]
	# pega o foco
	button.grab_focus()

func _on_button_fer_pegar_pressed() -> void:
	await _receber_input("pickup")
	_ajustar_texto_botao_evento(btns_pegar[0])

func _on_button_fer_pegar2_pressed() -> void:
	await _receber_input("pickup")
	_ajustar_texto_botao_evento(btns_pegar[1])


func _on_button_fer_largar_pressed() -> void:
	await _receber_input("drop")
	_ajustar_texto_botao_evento(btns_largar[0])

func _on_button_fer_largar2_pressed() -> void:
	await _receber_input("drop")
	_ajustar_texto_botao_evento(btns_largar[1])


func _on_button_fer_usar_pressed() -> void:
	await _receber_input("interact")
	_ajustar_texto_botao_evento(btns_usar[0])

func _on_button_fer_usar2_pressed() -> void:
	await _receber_input("interact")
	_ajustar_texto_botao_evento(btns_usar[1])


const action_names = [
	#"move_left",
	#"move_right",
	#"move_up",
	#"move_down",
	#"interact",
	#"pickup",
	#"drop",
	# controller only
	
	"throw_force",
	#"aim_left",
	#"aim_right",
	#"aim_up",
	#"aim_down",
]






	
	
	#var tex := $VBoxConfigs/GridContainerControles/LabelFerramenta2
	#
	#for ctr_btn in InputManager.Controle_btn.values():
		#tex.text = InputManager.PS_btn_nomes[ctr_btn]
		#await get_tree().create_timer(0.5).timeout
	
	#tex.text = "\u25A1 Square Button\n"
	#tex.text += "\u25B3 Triangulo Button\n"
	#tex.text += "\u25CB Bola Button\n"
	#tex.text += "\U01F150 A\n"
	#tex.text += "\u23F5 start\n"
	#tex.text += "\U01F53C up\n"
	
