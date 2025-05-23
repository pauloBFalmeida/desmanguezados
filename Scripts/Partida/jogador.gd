extends CharacterBody2D

@export var player_id := InputManager.PlayerId.P1

@export var speed: float = 250.0

# acoes do InputMap
var actionMap : Dictionary

@onready var area_interacao : Area2D = $AreaInteracao

var segurando_ferramenta : Ferramenta = null

func _ready() -> void:
	# ajusta o action map do player
	actionMap = InputManager.actionMap_players[player_id]
	# ajusta o nome
	set_name('Jogador_id_' + str(player_id))

func _process(delta: float) -> void:
	var move_dir = Input.get_vector(actionMap["move_left"], actionMap["move_right"], actionMap["move_up"], actionMap["move_down"])
	
	velocity = move_dir * speed
	move_and_slide()
	
	if Input.is_action_just_pressed(actionMap["action"]):
		acao()

# ------ Acao -------
func acao() -> void:
	# se nao tiver nada na area -> nao faca nada
	if bodys_dentro_area.is_empty(): return
	
	var body : Node2D
	# so 1 body dentro -> pega esse
	if bodys_dentro_area.size() == 1:
		for _body in bodys_dentro_area.values():
			body = _body
	# mais de 1 body dentro -> pega o mais proximo da direcao do movimento
	else:
		var direcao : Vector2 = (global_position - pos_inicio_interacao).normalized()
		var prox_posicao = global_position + direcao # extrapolacao da posicao global que o jogador "esta" se movendo
		# acha o body mais proximo de "prox_posicao"
		var min_dist : float = INF
		var min_body : Node2D = null
		for _body : Node2D in bodys_dentro_area.values():
			var dist = _body.global_position.distance_squared_to(prox_posicao)
			# se atual for menor do q o temos marcado -> vira o marcado
			if dist < min_dist:
				min_dist = dist
				min_body = _body
		body = min_body
	# fazemos a acao sobre o corpo
	if body.is_in_group("Ferramentas"):
		pegar_ferramenta(body)
		bodys_dentro_area.erase(body)
	elif body.is_in_group("Marcador"):
		print("usando: ", segurando_ferramenta)
		print("em: ", body)
	else:
		print('body escolhido: ', body)

func pegar_ferramenta(ferramenta : Ferramenta) -> void:
	segurando_ferramenta = ferramenta
	# ajusta para a area de interacao reconhecer o alvo da ferramenta
	area_interacao.set_collision_mask_value(ferramenta.get_layer_acao(), true)
	# TODO: Pegar a ferramenta msm
	
	# --- temp : rouba a sprite ---
	var sprite = ferramenta.get_node("Icon")
	sprite.get_parent().remove_child(sprite)
	# add
	add_child(sprite)
	sprite.scale = Vector2.ONE * 0.4
	sprite.position = Vector2.ZERO
	# remove a ferramenta do mapa
	ferramenta.queue_free()

# ------ Area Interacao -------
var bodys_dentro_area := {}
var pos_inicio_interacao : Vector2
func _on_area_interacao_body_entered(body: Node2D) -> void:
	bodys_dentro_area[body] = body
	pos_inicio_interacao = global_position
	print(body)

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if bodys_dentro_area.has(body):
		bodys_dentro_area.erase(body)
