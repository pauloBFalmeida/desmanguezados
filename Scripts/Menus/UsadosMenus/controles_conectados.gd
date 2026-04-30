extends Control

@onready var label_status_P1 := $LabelStatusP1
@onready var label_status_P2 := $LabelStatusP2

@onready var label_por_player_id := {
	InputManager.PlayerId.P1: $LabelP1,
	InputManager.PlayerId.P2: $LabelP2,
}

@onready var controles_manager: ControlesManager = $ControlesManager
@onready var label_info: Label = $LabelInfo

func _ready() -> void:
	label_info.hide()
	
	# online
	if NetworkingGame.is_game_online:
		_pegar_nomes_online()
		_set_P1_keyboard()
		InputManager.controle_added.connect(_pegar_nomes_online)
		return
	
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	
	# verifica se tem controles
	verificar_controle_contectado()
	
	# atualiza no inicio
	update_conectados()

## Verifica se tem controles conectados no PC, mas nao controlando os siris
## 	Se tiver controles nessa condicao, execute show_info_conectar_controle()
func verificar_controle_contectado() -> void:
	# se nao tem nenhum controle ligado no pc, pare
	if Input.get_connected_joypads().is_empty():
		return
	
	# se ja tem um controle conectado e ajustado pro jogo, pare
	if not InputManager.controles_conectados.is_empty():
		return
	
	# se tem exatamente 1 controle, adicione ao automaticamente, e pare
	if Input.get_connected_joypads().size() == 1:
		controles_manager.add_controller(Input.get_connected_joypads()[0])
		return
	
	# se tiver mais de 1 controle
	show_info_conectar_controle()

## Mostra o info com qual botao apertar para conectar o controle
func show_info_conectar_controle() -> void:
	# pega o botao que conecta o controle no jogo
	var conectar_btn : String = InputManager.get_text_controle_btn(InputManager.PlayerId.P1, InputManager.Controle_btn.START)
	# atualiza o texto
	label_info.text = "Conecte o controle com\n" + conectar_btn
	_flash_node(label_info)
	# mostre a label
	label_info.show()

# --- Controles Conectados ---
func update_conectados():
	# -- atualiza as labels --
	label_status_P1.text = _get_texto_input_player(InputManager.PlayerId.P1)
	label_status_P2.text = _get_texto_input_player(InputManager.PlayerId.P2)
	# -- esconde a label se ja tiver um controle --
	if (_is_controle_conectado_player(InputManager.PlayerId.P1) or 
			_is_controle_conectado_player(InputManager.PlayerId.P2) ):
		label_info.hide()

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
	if not Globais.ajustado_keyboard_controles:
		Globais.ajustado_keyboard_controles = true
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
