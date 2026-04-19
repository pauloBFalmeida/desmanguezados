@abstract
class_name SistemaOnline
extends Node

func _init() -> void:
	if not NetworkingGame.is_game_online:
		queue_free()

func _ready() -> void:
	await get_tree().process_frame
	
	iniciar_online_config()

func iniciar_online_config() -> void:
	pass
