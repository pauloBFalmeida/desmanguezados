extends Node

func _input(event):
	if event.is_action_pressed("contr_start"):
		var device_id = event.device
		if not InputManager.controles_conectados.has(device_id):
			# Adiciona primeiro o controle do P2, dps o do P1
			var player_id := InputManager.PlayerId.P2 if InputManager.controles_conectados.is_empty() else InputManager.PlayerId.P1
			# adiciona o inputmap pro controle
			InputManager.add_controller(player_id, device_id)

#func _set_device_id(player: Node, device_id: int) -> void:
	### give it a name so it's unique, if you really want
	#player.set_name('player' + str(device_id))
#
	### Give the player instance a device id so it can handle its own events
	#player.device_id = device_id
	### register the player in the players dict
	#players[device_id] = player
	#
	#player.action = InputManager.actions_player[player.player_id]
#
#func _input(event):
	#var device_id = event.device
	 ### Check to see that that event id on an action
	#if event.is_action_pressed("contr_start") and not players.get(device_id):
		##
		#InputManager.add_controller(1, device_id)
		#
		### create the player scene instance
		#var playerScene = preload("res://Cenas/player.tscn")
		#var player = playerScene.instantiate()
#
		#_set_device_id(player, device_id)
#
		### Add the player to the scene
		#add_child(player)
		#player.global_position = Vector2(100, 100)
		#
	#if event.is_action_pressed("key_start"):
		### create the player scene instance
		#var playerScene = preload("res://Cenas/player.tscn")
		#var player = playerScene.instantiate()
#
		### Add the player to the scene
		#add_child(player)
		#player.global_position = Vector2(100, 100)
		#
