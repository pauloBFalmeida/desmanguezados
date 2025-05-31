extends CharacterBody2D

@export var player_id := InputManager.PlayerId.P1

@export var speed: float = 250.0

@export var ferramentas_mgmt : Node2D

@onready var area_interacao : Area2D = $AreaInteracao
@onready var sprite := $Sprite2DJogador

var segurando_ferramenta : Ferramenta.Ferramenta_tipo = Ferramenta.Ferramenta_tipo.NONE

var ferramenta_collision_mask : int

# -- Input --
var move_left: StringName
var move_right: StringName
var move_up: StringName
var move_down: StringName
var interact: StringName
var drop: StringName

func _ready() -> void:
	_ajustar_input_map()
	# ajusta o nome
	set_name('Jogador_id_' + str(player_id))
	# ajeita o sprite
	anim_idle()

func _ajustar_input_map() -> void:
	# ajusta o action map do player
	var actionMap : Dictionary = InputManager.actionMap_players[player_id]
	
	move_left  = actionMap["move_left"]
	move_right = actionMap["move_right"]
	move_up    = actionMap["move_up"]
	move_down  = actionMap["move_down"]
	interact   = actionMap["interact"]
	drop       = actionMap["drop"]

func _process(delta: float) -> void:
	var move_dir = Input.get_vector(move_left, move_right, move_up, move_down)
	
	velocity = move_dir * speed
	move_and_slide()
	
	if Input.is_action_just_pressed(interact):
		acao()
	if Input.is_action_just_pressed(drop):
		drop_ferramenta()

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
	elif body.is_in_group("Marcador"):
		print("usando: ", segurando_ferramenta)
		print("em: ", body)
		usar_ferramenta(body)
	else:
		print('body escolhido: ', body)


# ------ Usar -------
func usar_ferramenta(body : Node2D) -> void:
	match (segurando_ferramenta):
		Ferramenta.Ferramenta_tipo.CORTAR:
			#TODO: Cortar arvore
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(body, "modulate:a", 0.3, 0.2)
			tween.finished.connect(func():
				var tween2 = create_tween()
				tween2.set_ease(Tween.EASE_OUT)
				tween2.tween_property(body, "modulate:a", 1.0, 0.2)
			)
		Ferramenta.Ferramenta_tipo.PLANTAR:
			pass
		Ferramenta.Ferramenta_tipo.RECOLHER:
			var lixo = body
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(lixo, "modulate:a", 0.0, 0.5).from_current()
			tween.finished.connect( func():
				lixo.queue_free() ### TODO fix this
			)

# ------ Pegar -------
func pegar_ferramenta(ferramenta : Ferramenta) -> void:
	# se ja estiver segurando uma ferramenta, nao faca nada
	if segurando_ferramenta != Ferramenta.Ferramenta_tipo.NONE: return
	
	segurando_ferramenta = ferramenta.tipo_ferramenta
	# ajusta para a area de interacao reconhecer o alvo da ferramenta
	ferramenta_collision_mask = ferramenta.get_layer_acao()
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, true)
	# anim pegar a ferramenta
	anim_segurar_ferramenta(segurando_ferramenta)
	# remove a ferramenta do mapa
	print('antes', bodys_dentro_area)
	bodys_dentro_area.erase(ferramenta)
	print('depois', bodys_dentro_area)
	ferramenta.queue_free()

# ------ Dropar -------
func drop_ferramenta() -> void:
	# se n tiver segurando nenhuma ferramenta, nao faca nada
	if segurando_ferramenta == Ferramenta.Ferramenta_tipo.NONE: return
	
	# spawn a ferramenta no chao
	var pos_ferramenta = global_position + Vector2(-15, 40)
	ferramentas_mgmt.spawn_ferramenta(segurando_ferramenta, pos_ferramenta)
	# area de interacao nao reconhece mais o alvo da ferramenta
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, false)
	ferramenta_collision_mask = 32
	# limpa a mao
	segurando_ferramenta = Ferramenta.Ferramenta_tipo.NONE
	anim_idle()

# ------ Animacao -------
func anim_segurar_ferramenta(tipo_ferramenta : Ferramenta.Ferramenta_tipo) -> void:
	match tipo_ferramenta:
		Ferramenta.Ferramenta_tipo.CORTAR:
			# sprite com machado dependendo da cor
			if player_id == InputManager.PlayerId.P1:
				sprite.texture = preload("res://Assets/Personagem/blue axe 1x.png")
			else:
				sprite.texture = preload("res://Assets/Personagem/Red axe x1.png")
			# ajeita a posicao
			sprite.region_rect = Rect2(10, 17, 42, 27)
			sprite.offset = Vector2(0, 4)
		Ferramenta.Ferramenta_tipo.PLANTAR:
			pass
		Ferramenta.Ferramenta_tipo.RECOLHER:
			sprite.modulate = Color.SANDY_BROWN
			print("omg 0000000")
			pass
		Ferramenta.Ferramenta_tipo.NONE:
			anim_idle()

func anim_idle() -> void:
	# sprite com machado dependendo da cor
	if player_id == InputManager.PlayerId.P1:
		sprite.texture = preload("res://Assets/Personagem/bluex1.png")
	else:
		sprite.texture = preload("res://Assets/Personagem/Redx1.png")
	# ajeita a posicao
	sprite.region_rect = Rect2(10, 31, 42, 19)
	sprite.offset = Vector2.ZERO

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
