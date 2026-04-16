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
	var is_controle_conectado : bool = false
	# Encontra os players com os controles conectados
	for device_id in InputManager.controles_conectados:
		var controle_player_id = InputManager.controles_conectados[device_id]
		if player_id == controle_player_id:
			is_controle_conectado = true
			break
	# se tiver controle conectado pro player, retorna o texto do controle
	if is_controle_conectado:
		return _get_controle_texto(player_id)
	# se nao tiver controle, retorna WASD pro P1, Setas pro P2
	if   player_id == InputManager.PlayerId.P1:
		return "WASD"
	elif player_id == InputManager.PlayerId.P2:
		return "Setas"
	
	return ""

func _get_controle_texto(player_id : InputManager.PlayerId) -> String:
	var controle_tipo :	InputManager.Controle_tipo
	controle_tipo = Globais.controle_tipo_player[player_id]
	return ("Controle "
			+ InputManager.controle_tipo_string[controle_tipo]
			+ " Conectado")

# --- Online ---
func _pegar_nomes_online() -> void:
	# --- Jogador principal (desse computador) ---
	# pega o PlayerId
	var player_id : InputManager.PlayerId = NetworkingGame.jogador_player_id
	var nome: String = NetworkingGame.jogador_nome
	_mudar_nome_player(player_id, nome)
	
	# coloca efeito de flash no nome do jogador
	_flash_node(label_por_player_id[player_id])
	
	# mostra os controles do P1 para o jogador (independente se online ele eh o P2)
	if player_id == InputManager.PlayerId.P1:
		label_status_P1.text = _get_texto_input_player(InputManager.PlayerId.P1)
	else:
		label_status_P2.text = _get_texto_input_player(InputManager.PlayerId.P1)
	
	# --- Jogador companion (online) ---
	
	# pega os dados
	player_id = InputManager.get_other_player_id(player_id)
	nome = NetworkingGame.nomes_por_id[Networking.companion_peer_id]
	_mudar_nome_player(player_id, nome)
	
	# esconder os controles do outro player
	if player_id == InputManager.PlayerId.P1:
		label_status_P1.hide()
	else:
		label_status_P2.hide()

func _mudar_nome_player(player_id : InputManager.PlayerId, nome : String) -> void:
	var label : Label = label_por_player_id[player_id]
	label.text = nome

func _flash_node(node : Node) -> void:
	print('flash')
	var tween := create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "modulate:a", 0.6, 2)
	tween.tween_property(node, "modulate:a", 1.0, 2)
