extends Node

func _input(event):
	# controle start foi pressionado
	if event.is_action_pressed("contr_start"):
		var device_id = event.device
		# se o controle nao foi adicionado ainda
		if not InputManager.controles_conectados.has(device_id):
			# Adiciona primeiro o controle do P2, dps o do P1
			var player_id := InputManager.PlayerId.P2 if InputManager.controles_conectados.is_empty() else InputManager.PlayerId.P1
			# adiciona o inputmap pro controle
			InputManager.add_controller(player_id, device_id)
