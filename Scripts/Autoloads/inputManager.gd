extends Node

signal controle_added

# id de cada jogador
enum PlayerId {
	P1,
	P2
}

# nome das acaos
const action_names = [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"interact",
	"pickup",
	"drop",
	# controller only
	"throw_force",
	"aim_left",
	"aim_right",
	"aim_up",
	"aim_down",
]

enum Controle_tipo {PS, XBOX, SWITCH}

const controle_tipo_string : Dictionary[Controle_tipo, String] = {
	Controle_tipo.PS : "PS",
	Controle_tipo.XBOX : "Xbox",
	Controle_tipo.SWITCH : "Switch",
}

# actionMap_players[player id] -> acoes[nome da acao (do action_names)] -> nome da acao pro player no InputMap
var actionMap_players = {}

# controles conectados [controle id] -> player id
var controles_conectados : Dictionary[int, PlayerId] = {}

var players_no_controle : Array[PlayerId]

func _ready() -> void:
	set_default_keyboard()

# padrao do keyboard para ambos os players
func set_default_keyboard() -> void:
	for player_id in PlayerId.values():
		add_keyboard(player_id)

# ----- Adiciona as actionMap para o teclado ----
func add_keyboard(player_id: PlayerId):
	# se nao tiver mapa de acoes pro player -> crie
	if not actionMap_players.has(player_id):
		actionMap_players[player_id] = {}
	# add as acoes do keyboard para esse player
	var prefix = "key_1_" if player_id == PlayerId.P1 else "key_2_"
	for action_name in action_names:
		var ref_name: String = prefix + action_name
		actionMap_players[player_id][action_name] = ref_name
	# controles personalizados salvos para esse player 
	# 	se tiver -> entao coloque essas acoes e acabe a funcao
	# 	se nao tiver -> continue a funcao
	#	false -> pois nao eh no controle, e sim no teclado
	SaveManager.load_player_input(player_id, false)

# ---- Adiciona as actionMap para controle ----
func add_controller(player_id: PlayerId, device_id: int) -> void:
	controles_conectados[device_id] = player_id
	players_no_controle.append(player_id) # marca esse jogador como no controle
	# se nao tiver mapa de acoes pro player -> crie
	if not actionMap_players.has(player_id):
		actionMap_players[player_id] = {}
	# copia as acoes do controle, especifico do device_id do controle
	for action_name in action_names:
		var new_name: String = action_name + "_" +str(device_id)
		var ref_name: String = "contr_" + action_name
		_clone_action_controller(ref_name, new_name, device_id)
		actionMap_players[player_id][action_name] = new_name
	# controles personalizados salvos para esse player 
	#	true -> pois este jogador esta usando o controle
	SaveManager.load_player_input(player_id, true)
	# emite o sinal avisando que foi adicionado um controle
	emit_signal("controle_added")

func _clone_action_controller(original: String, new_name: String, device_id: int):
	# se nao tiver uma acao com esse nome -> crie
	if not InputMap.has_action(new_name):
		InputMap.add_action(new_name)
	# copia todos os eventos da acao "original" para a acao "new_name"
	for event in InputMap.action_get_events(original):
		var event_copy = event.duplicate()
		# so para o device com o id desejado
		event_copy.device = device_id
		InputMap.action_add_event(new_name, event_copy)

func remove_actions_input(player_id: PlayerId, action_name: String) -> void:
	# se o player ainda nao tiver acoes no actionMap -> acabe, pois nao tem o que remover
	if ( (not actionMap_players.has(player_id)) or
		 (not actionMap_players[player_id].has(action_name)) ): return
	# pega a acao
	var action : String = actionMap_players[player_id][action_name]
	# se tiver a acao no inputmap -> remova os eventos associados
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)

func change_action_input(player_id: PlayerId, action_name: String, action_event: InputEvent) -> void:
	var action : String = actionMap_players[player_id][action_name]
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, action_event)

func add_action_input(player_id: PlayerId, action_name: String, action_event: InputEvent) -> void:
	# pega a acao e adicione o evento
	var action : String = actionMap_players[player_id][action_name]
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_add_event(action, action_event)

func get_action_events(player_id: PlayerId, action_name: String) -> Array[InputEvent]:
	var action : String = actionMap_players[player_id][action_name]
	if InputMap.has_action(action):
		return InputMap.action_get_events(action)
	return []

# ---------- Nomes Botoes ---------------
enum Controle_btn {
	A, B, X, Y,
	LB, RB, LT, RT, 
	UP, DOWN, LEFT, RIGHT,
	JL, JR, # press joystick
	SELECT, START,
	NONE
}

const controle_btn_nomes : Dictionary[Controle_tipo, Dictionary] = {
	Controle_tipo.PS: PS_btn_nomes,
	Controle_tipo.XBOX: Xbox_btn_nomes,
	Controle_tipo.SWITCH: Switch_btn_nomes,
}

const PS_btn_nomes : Dictionary[Controle_btn, String] = {
	Controle_btn.A: "\u2613",
	Controle_btn.B: "\u25CB",	# Bolinha
	Controle_btn.X: "\u2610", #"\u25A2", #"\u25A1", 	# Quadrado
	Controle_btn.Y: "\u25B3", 	# Triangulo
	Controle_btn.LB: "L1",
	Controle_btn.RB: "R1",
	Controle_btn.LT: "L2",
	Controle_btn.RT: "R2",
	Controle_btn.JL: "\u24C1", # joystick press Left
	Controle_btn.JR: "\u24C7", # joystick press Right
	Controle_btn.UP: "\u23F6",
	Controle_btn.DOWN: "\u23F7",
	Controle_btn.LEFT: "\u23F4",
	Controle_btn.RIGHT: "\u23F5",
	Controle_btn.SELECT: "\u25AC",
	Controle_btn.START: "\u27A4",#"\u25BA",
}
const Xbox_btn_nomes : Dictionary[Controle_btn, String] = {
	Controle_btn.A: "\U01F150", # A
	Controle_btn.B: "\U01F151", # B
	Controle_btn.X: "\U01F167", # X
	Controle_btn.Y: "\U01F168", # Y
	Controle_btn.LB: "LB",
	Controle_btn.RB: "RB",
	Controle_btn.LT: "LT",
	Controle_btn.RT: "RT",
	Controle_btn.JL: "\u24C1", # joystick press Left
	Controle_btn.JR: "\u24C7", # joystick press Right
	Controle_btn.UP: "\u23F7",
	Controle_btn.DOWN: "\u23F6",
	Controle_btn.LEFT: "\u23F4",
	Controle_btn.RIGHT: "\u23F5",
	Controle_btn.SELECT: "\u274F",
	Controle_btn.START: "\u2630",
}

const Switch_btn_nomes : Dictionary[Controle_btn, String] = {
	Controle_btn.A: "\U01F151", # B
	Controle_btn.B: "\U01F150", # A
	Controle_btn.X: "\U01F168", # Y
	Controle_btn.Y: "\U01F167", # X
	Controle_btn.LB: "L",
	Controle_btn.RB: "R",
	Controle_btn.LT: "ZL",
	Controle_btn.RT: "ZR",
	Controle_btn.JL: "\u24C1", # joystick press Left
	Controle_btn.JR: "\u24C7", # joystick press Right
	Controle_btn.UP: "\u23F7",
	Controle_btn.DOWN: "\u23F6",
	Controle_btn.LEFT: "\u23F4",
	Controle_btn.RIGHT: "\u23F5",
	Controle_btn.SELECT: "\u25D9",
	Controle_btn.START: "\u2302",
}

const controle_btn_indexes : Dictionary[Controle_tipo, Dictionary] = {
	Controle_tipo.PS: PS_btn_index,
	#Controle_tipo.XBOX: PS_btn_index,
	#Controle_tipo.SWITCH: PS_btn_index,
}

const PS_btn_index : Dictionary[int, Controle_btn] = {
	0:  Controle_btn.A,
	1:  Controle_btn.B,
	2:  Controle_btn.X,
	3:  Controle_btn.Y,
	4:  Controle_btn.SELECT,
	6:  Controle_btn.START,
	7:  Controle_btn.JL,
	8:  Controle_btn.JR,
	9:  Controle_btn.LB,
	10: Controle_btn.RB,
	11: Controle_btn.UP,
	12: Controle_btn.DOWN,
	13: Controle_btn.LEFT,
	14: Controle_btn.RIGHT,
}

func get_texto_acao(data : Dictionary, player : PlayerId) -> String:
	# se nao tiver nada -> retorne '-'
	if data.is_empty(): return '-'
	
	if data["on_controle"]: # -- controle --
		# pega o botao do controle
		var controle_button := InputManager.Controle_btn.NONE
		controle_button = data["button"]
		# caso seja invalido
		if controle_button == InputManager.Controle_btn.NONE:
			return '-'
		
		# tipo de controle (PS, Xbox ...)
		var controle_tipo = Globais.controle_tipo_player[player]
		# pega a String que representa o botao
		var btn_nomes = InputManager.controle_btn_nomes[controle_tipo]
		# retorna o texto
		return btn_nomes[controle_button]
	else: # -- mouse teclado --
		# mouse
		if data["on_mouse"]:
			match data["button"]:
				MouseButton.MOUSE_BUTTON_LEFT:
					return "Mouse E"
				MouseButton.MOUSE_BUTTON_RIGHT:
					return "Mouse D"
				MouseButton.MOUSE_BUTTON_MIDDLE:
					return "Mouse Meio"
				MouseButton.MOUSE_BUTTON_XBUTTON1:
					return "Mouse E1"
				MouseButton.MOUSE_BUTTON_XBUTTON2:
					return "Mouse E2"
		# teclado
		else:
			if (data.has("unicode") and data["unicode"] != 0 
					and data["unicode"] != 32 # space
					):
				return char(data["unicode"])
			else:
				var keycode := DisplayServer.keyboard_get_keycode_from_physical(data["physical_keycode"])
				return OS.get_keycode_string(keycode)
	# nao deve cair aqui
	return '-'

func get_event_data(event : InputEvent, player : PlayerId, escutar_input : bool = false) -> Dictionary:
	var data := {}
	# controle
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		data["on_controle"] = true
		if event is InputEventJoypadButton:
			var controle_tipo = Globais.controle_tipo_player[player]
			var btn_index = InputManager.controle_btn_indexes[controle_tipo]
			var id = event.button_index
			if btn_index.has(id):
				data["button"] = btn_index[id]
				data["controle_tipo"] = controle_tipo
				return data
		elif event is InputEventJoypadMotion:
			# se for LT ou RT (trigger) garante que tenha apertado um pouco
			#	para evitar apertos acidentais ou deadzones 
			if escutar_input and event.axis_value < 0.4: return {}
			# se nao estiver escutando por inputs, ou passar do threshold
			if event.axis == JOY_AXIS_TRIGGER_LEFT:
				data["button"] = InputManager.Controle_btn.LT
				return data
			elif event.axis == JOY_AXIS_TRIGGER_RIGHT:
				data["button"] = InputManager.Controle_btn.RT
				return data
	# mouse e teclado
	elif event is InputEventKey or event is InputEventMouseButton:
		data["on_controle"] = false
		if event is InputEventKey:
			data["on_mouse"] = false
			if event.unicode != 0:
				data["unicode"] = event.unicode
			data["physical_keycode"] = event.physical_keycode
		elif event is InputEventMouseButton:
			data["on_mouse"] = true
			data["button"] = event.button_index
		return data
	# se chegou aqui, nao caiu em nada antes -> retorne invalido
	return {}
