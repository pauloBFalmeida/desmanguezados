extends Node

func _input(event):
	# controle start foi pressionado
	if event.is_action_pressed("contr_start"):
		var device_id = event.device
		# se o controle nao foi adicionado ainda
		if not InputManager.controles_conectados.has(device_id):
			# adiciona o controle
			_add_controller(device_id)

## Associa o controle para um dos jogadores
func _add_controller(device_id: int) -> void:
	# Decide pra qual jogar vai o controle
	var player_id := _decidir_jogador()
	# adiciona o inputmap pro controle
	InputManager.add_controller(player_id, device_id)

## Decide pra qual jogar vai o controle
func _decidir_jogador() -> InputManager.PlayerId:
	if NetworkingGame.is_game_online:
		# adiciona controle pro siri que o jogador esta controlando
		return NetworkingGame.jogador_player_id
	else:
		# Adiciona primeiro o controle do P2, dps o do P1
		return InputManager.PlayerId.P2 if InputManager.controles_conectados.is_empty() else InputManager.PlayerId.P1
