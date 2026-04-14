extends Control

@onready var label_status_P1 := $LabelStatusP1
@onready var label_status_P2 := $LabelStatusP2

@onready var label_por_player_id := {
	InputManager.PlayerId.P1: $LabelP1,
	InputManager.PlayerId.P2: $LabelP2,
}

func _ready() -> void:
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	update_conectados() # atualiza no inicio
	# online
	if NetworkingGame.is_game_online:
		_pegar_nomes_online()

# --- Controles Conectados ---
func update_conectados():
	# dict de quais controles foram conectados
	var is_controle_conectado := {
		InputManager.PlayerId.P1: false,
		InputManager.PlayerId.P2: false
	}
	# Encontra os players com os controles conectados
	for device_id in InputManager.controles_conectados:
		var player_id = InputManager.controles_conectados[device_id]
		is_controle_conectado[player_id] = true
	
	# -- atualiza as labels --
	# Player 1
	if is_controle_conectado[InputManager.PlayerId.P1]:
		label_status_P1.text = _get_controle_texto(InputManager.PlayerId.P1)
	else:
		label_status_P1.text = "WASD"
	# Player 2
	if is_controle_conectado[InputManager.PlayerId.P2]:
		label_status_P2.text = _get_controle_texto(InputManager.PlayerId.P2)
	else:
		label_status_P2.text = "Setas"

func _get_controle_texto(player_id : InputManager.PlayerId) -> String:
	var controle_tipo :	InputManager.Controle_tipo
	controle_tipo = Globais.controle_tipo_player[player_id]
	return ("Controle "
			+ InputManager.controle_tipo_string[controle_tipo]
			+ " Conectado")

# --- Online ---
func _pegar_nomes_online() -> void:
	# pega o PlayerId
	var player_id : InputManager.PlayerId = NetworkingGame.jogador_player_id
	var nome: String = NetworkingGame.jogador_nome
	_mudar_nome_player(player_id, nome)
	
	# efeito no nome do proprio jogador
	_flash_node(label_por_player_id[player_id])
	
	# do outro jogador
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
