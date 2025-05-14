class_name Level
extends Node

#var players = {}
#
#func create_players() -> void:	
	#for player_id in InputManager.PlayerId.values():
		## instancia o player
		#var playerScene = preload("res://Cenas/player.tscn")
		#var player = playerScene.instantiate()
		#player.player_id = player_id
		## ajusta o action map do player
		#player.action = InputManager.actions_player[player.player_id]
		## ajusta o nome
		#player.set_name('player' + str(player_id))
		## salva no dicionario
		#players[player_id] = player
		## coloca na hierarquia
		#add_child(player)
		## posiciona e muda de cor
		#if player_id == InputManager.PlayerId.P1:
			#player.global_position = Vector2(100, 100)
			#player.modulate.r = 0
		#else:
			#player.global_position = Vector2(200, 100)
			#player.modulate.b = 0
