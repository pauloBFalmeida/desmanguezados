@abstract
class_name SistemaOnline
extends Node

func _init() -> void:
	if not NetworkingGame.is_game_online:
		queue_free()

func _ready() -> void:
	# espera 1 frame antes de comecar a config online
	await get_tree().process_frame
	iniciar_online_config()

## Iniciar as configuracoes do Sistema Online, apos o primeiro frame
func iniciar_online_config() -> void:
	pass
