extends Control

@onready var label_status_P1 := $LabelStatusP1
@onready var label_status_P2 := $LabelStatusP2

@onready var label_por_player_id := {
	InputManager.PlayerId.P1: $LabelP1,
	InputManager.PlayerId.P2: $LabelP2,
}

func _ready() -> void:
	# online
	if NetworkingGame.is_game_online:
		_pegar_nomes_online()
		_set_P1_keyboard()
		InputManager.controle_added.connect(_pegar_nomes_online)
		return
	
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	update_conectados() # atualiza no inicio

# --- Controles Conectados ---
func update_conectados():
	# -- atualiza as labels --
	label_status_P1.text = _get_texto_input_player(InputManager.PlayerId.P1)
	label_status_P2.text = _get_texto_input_player(InputManager.PlayerId.P2)

func _get_texto_input_player(player_id : InputManager.PlayerId) -> String:
	# se tiver controle conectado pro player, retorna o texto do controle
	if _is_controle_conectado_player(player_id):
		return _get_controle_texto(player_id)
	
	# se nao tiver controle, retorna WASD pro P1, Setas pro P2
	if   player_id == InputManager.PlayerId.P1:
		return "WASD"
	elif player_id == InputManager.PlayerId.P2:
		return "Setas"
	
	return ""

func _is_controle_conectado_player(player_id : InputManager.PlayerId) -> bool:
	# Encontra os players com os controles conectados
	for device_id in InputManager.controles_conectados:
		var controle_player_id = InputManager.controles_conectados[device_id]
		if player_id == controle_player_id:
			return true
	return false

func _get_controle_texto(player_id : InputManager.PlayerId) -> String:
	var controle_tipo :	InputManager.Controle_tipo
	controle_tipo = Globais.controle_tipo_player[player_id]
	return ("Controle "
			+ InputManager.controle_tipo_string[controle_tipo]
			+ " Conectado")

# --- Online ---

## Coloca os controles do P1 no siri que o jogador esta controlando
func _set_P1_keyboard() -> void:
	var player_id : InputManager.PlayerId = NetworkingGame.jogador_player_id
	InputManager.add_keyboard(player_id, InputManager.PlayerId.P1)

func _pegar_nomes_online() -> void:
	# --- Jogador principal (desse computador) ---
	# pega o PlayerId
	var player_id : InputManager.PlayerId = NetworkingGame.jogador_player_id
	var nome: String = NetworkingGame.jogador_nome
	_mudar_nome_player(player_id, nome)
	
	# coloca efeito de flash no nome do jogador
	_flash_node(label_por_player_id[player_id])
	
	# mostra os comandos do P1 para o jogador
	var texto_comandos : String = ""
	# se ele tiver de controle -> mostra o controle
	if _is_controle_conectado_player(player_id):
		texto_comandos = _get_controle_texto(player_id)
	# se nao tiver controle -> mostra os comandos do player 1 (independente se online ele eh o P2)
	else:
		texto_comandos = _get_texto_input_player(InputManager.PlayerId.P1)
	
	# atualiza a label
	if player_id == InputManager.PlayerId.P1:
		label_status_P1.text = texto_comandos
	else:
		label_status_P2.text = texto_comandos
	
	# --- Jogador companion (online) ---
	
	# pega os dados
	player_id = InputManager.get_other_player_id(player_id)
	nome = NetworkingGame.nomes_por_id[Networking.companion_peer_id]
	_mudar_nome_player(player_id, nome)
	
	# Mostra como online o outro player
	if player_id == InputManager.PlayerId.P1:
		label_status_P1.text = "Online"
	else:
		label_status_P2.text = "Online"

func _mudar_nome_player(player_id : InputManager.PlayerId, nome : String) -> void:
	var label : Label = label_por_player_id[player_id]
	label.text = nome

func _flash_node(node : Node) -> void:
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "modulate:a", 0.6, 2)
	tween.tween_property(node, "modulate:a", 1.0, 2)
