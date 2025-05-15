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
	"move_down",
	"move_up",
	"action"
]

# actionMap_players[player id] -> acoes[nome da acao (do action_names)] -> nome da acao pro player no InputMap
var actionMap_players = {}

# controles conectados [controle id] -> player id
var controles_conectados = {}

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

# ---- Adiciona as actionMap para controle ----
func add_controller(player_id: PlayerId, device_id: int) -> void:
	controles_conectados[device_id] = player_id
	# se nao tiver mapa de acoes pro player -> crie
	if not actionMap_players.has(player_id):
		actionMap_players[player_id] = {}
	# copia as acoes do controle, especifico do device_id do controle
	for action_name in action_names:
		var new_name: String = action_name + "_" +str(device_id)
		var ref_name: String = "contr_" + action_name
		_clone_action_controller(ref_name, new_name, device_id)
		actionMap_players[player_id][action_name] = new_name
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
