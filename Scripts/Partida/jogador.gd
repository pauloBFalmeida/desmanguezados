extends Node2D

@export var player_id := InputManager.PlayerId.P1

@export var speed: float = 250.0

# acoes do InputMap
var action : Dictionary

func _ready() -> void:
	# ajusta o action map do player
	action = InputManager.actions_player[player_id]
	# ajusta o nome
	set_name('Jogador_id_' + str(player_id))

func _process(delta: float) -> void:
	var move_dir = Input.get_vector(action["move_left"], action["move_right"], action["move_up"], action["move_down"])
	
	global_position += move_dir * delta * speed
