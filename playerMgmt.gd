extends Node2D

var players = {}

func _set_device_id(player: Node, device_id: int) -> void:
	## give it a name so it's unique, if you really want
	player.set_name('player' + str(device_id))

	## Give the player instance a device id so it can handle its own events
	player.device_id = device_id
	## register the player in the players dict
	players[device_id] = player
	
	player.action = InputManager.actions_player[1]
	

func _input(event):
	var device_id = event.device
	 ## Check to see that that event id on an action
	if not players.get(device_id) and event.is_action_pressed("start"):
		#
		InputManager.add_controller(1, device_id)
		
		## create the player scene instance
		var playerScene = preload("res://Cenas/player.tscn")
		var player = playerScene.instantiate()

		_set_device_id(player, device_id)

		## Add the player to the scene
		add_child(player)
		player.global_position = Vector2(100, 100)
		
