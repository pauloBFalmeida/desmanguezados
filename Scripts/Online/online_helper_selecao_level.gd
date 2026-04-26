extends Node
class_name OnlineHelperSelecaoLevel

var menu_selecao : MenuSelecao

## Cria o OnlineHelperSelecaoLevel
static func criar(_menu_selecao : MenuSelecao) -> OnlineHelperSelecaoLevel:
	# cria o OnlineHelperSelecaoLevel
	var node_ref = load("uid://bexmg8hvs1d3b")
	var new_node = node_ref.instantiate()
	# ajusta o menu selecao
	var helperSelecao : OnlineHelperSelecaoLevel = new_node
	helperSelecao.menu_selecao = _menu_selecao
	# se adiciona no network game
	NetworkingGame.helper_selecao_level = helperSelecao
	# retorna o node 
	return helperSelecao


@export var sticker_offset_x : int = 75
@export var stickers_pck_por_player_id : Dictionary[InputManager.PlayerId, PackedScene]

@onready var timer_votos: Timer = $TimerVotos

@onready var popup_voltar: PopupPanel = $PopupPanelVoltar
@onready var button_ficar: Button = $PopupPanelVoltar/MarginContainer/VBox/ButtonFicar
@onready var button_voltar: Button = $PopupPanelVoltar/MarginContainer/VBox/ButtonVoltar

var stickers_por_player_id : Dictionary[InputManager.PlayerId, AnimatedSprite2D]
var level_votado_por_player_id : Dictionary[InputManager.PlayerId, LevelManager.Level_id]

func _ready() -> void:
	timer_votos.timeout.connect(_encerrar_votacao)
	
	# cria os stickers
	for player_id in [InputManager.PlayerId.P1, InputManager.PlayerId.P2]:
		var sticker_pkd := stickers_pck_por_player_id[player_id]
		var sticker : AnimatedSprite2D = sticker_pkd.instantiate()
		stickers_por_player_id[player_id] = sticker
		sticker.hide()
		add_child(sticker)
	
	# percorre todos os itens de leveis, trocando o iniciar partida por votar
	for level_item : LevelItem in menu_selecao.leveis_itens:
		# remove o sinal de apertar o botao com iniciar o level
		_disconnect_signal(level_item, "pressed")
		
		# conecta o apertar o botao do level, com _votar_level
		level_item.pressed.connect(_votar_level.bind(level_item.level_id))
	
	# exibe pop up no botao de voltar
	popup_voltar.hide()
	var btn_voltar : Button = menu_selecao.button_voltar
	_disconnect_signal(btn_voltar, "pressed")
	btn_voltar.pressed.connect(_mostrar_popup_voltar)
	# conecta os botoes do popup
	button_ficar.pressed.connect(_esconder_popup_voltar)
	button_voltar.pressed.connect(menu_selecao._on_button_voltar_pressed)

func _mostrar_popup_voltar() -> void:
	popup_voltar.show()
	button_ficar.grab_focus()

func _esconder_popup_voltar() -> void:
	popup_voltar.hide()
	menu_selecao.button_voltar.grab_focus()

func _disconnect_signal(node: Node, signal_name: String) -> void:
	var connections = node.get_signal_connection_list(signal_name)
	for connection in connections:
		node.disconnect(signal_name, connection["callable"])

func _votar_level(level_id : int) -> void:
	player_votou_level(level_id, NetworkingGame.jogador_player_id)
	NetworkingGame.votar_level.rpc_id(Networking.companion_peer_id, level_id, NetworkingGame.jogador_player_id)

func player_votou_level(level_id : int, player_id: InputManager.PlayerId) -> void:
	# -- conta o voto --
	level_votado_por_player_id[player_id] = level_id
	_verificar_votos()
	# -- Mostra o sticker --
	var sticker := stickers_por_player_id[player_id]
	# remove o pai do sticker
	sticker.get_parent().remove_child(sticker)
	# adiciona como filho do level
	var level : LevelItem = menu_selecao.leveis_itens_por_level_id[level_id]
	level.add_child(sticker)
	sticker.show()
	# posiciona dependendo do player
	if player_id == InputManager.PlayerId.P1:
		sticker.rotation_degrees = -5.0
		sticker.position.x = sticker_offset_x
	else:
		sticker.rotation_degrees = 5.0
		sticker.position.x = level.size.x
		sticker.position.x -= sticker_offset_x

func _verificar_votos() -> void:
	# se nao tiver os 2 votos, pare
	if not ( level_votado_por_player_id.has(InputManager.PlayerId.P1) and 
			 level_votado_por_player_id.has(InputManager.PlayerId.P2) ):
		return
	
	# se votaram no mesmo, inicie o timer 
	if level_votado_por_player_id[InputManager.PlayerId.P1] == level_votado_por_player_id[InputManager.PlayerId.P2]:
		timer_votos.start(timer_votos.wait_time)
		
	else:
		# se votaram em diferentes pare o timer
		timer_votos.stop()

func _encerrar_votacao() -> void:
	print("TODO: tela de iniciando partida, esperar 1 seg")
	# iniciar partida
	NetworkingGame.iniciar_partida(level_votado_por_player_id[InputManager.PlayerId.P1])
