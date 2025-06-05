extends CharacterBody2D
class_name Jogador

@export var player_id := InputManager.PlayerId.P1

## velocidade do jogador
@export var speed: float = 250.0
## porcentagem de slowdown no lodo
@export var slowdown_lodo: float = 0.75

@export var ferramentas_mgmt : Node2D
@export var tilemap_lodo : TileMapDual

@onready var area_interacao : Area2D = $AreaInteracao
#@onready var sprite := $Sprite2DJogador
@onready var anim_sprite := $AnimatedSprite2D

var segurando : Ferramenta = null

var ferramenta_collision_mask : int

var speed_modifier_terreno : float = 1.0
var speed_modifier_cooldown : float = 1.0

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
	set_name('Jogador_' + "P1" if player_id == InputManager.PlayerId.P1 else "P2")
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

func _physics_process(_delta: float) -> void:
	# pega o slow_speed do tilemap lodo
	var tile_pos = tilemap_lodo.local_to_map(global_position / tilemap_lodo.scale.x)
	var tile = tilemap_lodo.get_cell_tile_data(tile_pos)
	
	if tile != null: # se setiver emcima de um tile existente no tilemap
		var slow_speed : float = tile.get_custom_data("slow_speed")
		speed_modifier_terreno = slow_speed * slowdown_lodo
	else:
		speed_modifier_terreno = 1.0

func _process(_delta: float) -> void:
	var move_dir = Input.get_vector(move_left, move_right, move_up, move_down)
	
	velocity = move_dir * speed * speed_modifier_terreno * speed_modifier_cooldown
	move_and_slide()
	
	if Input.is_action_just_pressed(interact):
		acao()
	if Input.is_action_just_pressed(drop):
		drop_ferramenta()

# ------ Acao -------
func acao() -> void:	
	# se nao tiver nada na area -> nao faca nada
	if bodys_dentro_area.is_empty():
		balancar_ferramenta()
		return
	
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
		usar_ferramenta(body)
	else:
		print('body escolhido: ', body)


# ------ Usar -------
func usar_ferramenta(body : Node2D) -> void:
	# se nao tiver segurando uma ferramenta
	if (not segurando) or (not is_instance_valid(segurando)): return
	# usar a ferramenta
	segurando.usar_ferramenta(body)
	# aplica o cooldown na ferramenta e mostra no player
	cooldown_jogador(segurando)

func balancar_ferramenta() -> void:
	# se nao tiver segurando uma ferramenta
	if (not segurando) or (not is_instance_valid(segurando)): return
	# balancar a ferramenta
	segurando.balancar_ferramenta()

# ------ Pegar -------
func pegar_ferramenta(ferramenta : Ferramenta) -> void:
	# se ja estiver segurando uma ferramenta, nao faca nada
	if segurando and is_instance_valid(segurando): return
	
	segurando = ferramenta
	ferramentas_mgmt.jogador_pegar(self, ferramenta)
	
	# ajusta para a area de interacao reconhecer o alvo da ferramenta
	ferramenta_collision_mask = ferramenta.get_layer_acao()
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, true)
	# anim pegar a ferramenta
	anim_segurar_ferramenta(segurando)
	
	# remove a ferramenta dos bodies dentro da area de interacao do jogador
	bodys_dentro_area.erase(ferramenta)

# ------ Dropar -------
func drop_ferramenta() -> void:
	# se n tiver segurando nenhuma ferramenta, nao faca nada
	if (not segurando) or (not is_instance_valid(segurando)): return
	
	var ferramenta = segurando
	# limpa a mao
	segurando = null
	
	ferramentas_mgmt.jogador_soltar(self, ferramenta)
	
	# area de interacao nao reconhece mais o alvo da ferramenta
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, false)
	ferramenta_collision_mask = 32
	
	anim_idle()	

# ---- Cooldown da ferramenta ----
# TODO: melhorar essa parte de animacao
@export var cor_cooldown : Color
@onready var cor_cooldown_base : Color = modulate
var ja_tem_anim_cooldown : bool = false

func cooldown_jogador(ferramenta : Ferramenta) -> void:
	# se ja tiver rodando o cooldown
	if ja_tem_anim_cooldown: return
	# marca que esta aplicando o cooldown
	ja_tem_anim_cooldown = true
	
	# slow 
	speed_modifier_cooldown = 0.2
	
	# rodar animacao de piscar transparente
	var duracao := ferramenta.cooldown/2
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", cor_cooldown, duracao).from_current()
	tween.finished.connect( func():
		var tween2 := create_tween()
		tween2.set_ease(Tween.EASE_IN)
		tween2.set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(self, "modulate", cor_cooldown_base, duracao).from_current()
		# marca o fim do cooldown
		tween2.finished.connect( _fim_cooldown_jogador )
	)

func _fim_cooldown_jogador() -> void:
	ja_tem_anim_cooldown = false
	speed_modifier_cooldown = 1.0
	
# ------ Animacao -------
func anim_segurar_ferramenta(ferramenta : Ferramenta) -> void:
	var tipo_ferramenta : Ferramenta.Ferramenta_tipo = ferramenta.tipo_ferramenta
	match tipo_ferramenta:
		Ferramenta.Ferramenta_tipo.CORTAR:
			# sprite com machado dependendo da cor
			if player_id == InputManager.PlayerId.P1:
				anim_sprite.play("blueCortar")
				#sprite.texture = preload("res://Assets/Personagem/blue axe 1x.png")
			else:
				anim_sprite.play("redCortar")
				#sprite.texture = preload("res://Assets/Personagem/Red axe x1.png")
			# ajeita a posicao
			#sprite.region_rect = Rect2(10, 17, 42, 27)
			#sprite.offset = Vector2(0, 4)
		Ferramenta.Ferramenta_tipo.PLANTAR:
			if player_id == InputManager.PlayerId.P1:
				anim_sprite.play("bluePlantar")
			else:
				anim_sprite.play("redPlantar")
		Ferramenta.Ferramenta_tipo.RECOLHER:
			if player_id == InputManager.PlayerId.P1:
				anim_sprite.play("blueRecolher")
			else:
				anim_sprite.play("redRecolher")
		_: # default, caso nao de match com nenhuma das opcoes anteriores
			anim_idle()

func anim_idle() -> void:
	if player_id == InputManager.PlayerId.P1:
		anim_sprite.play("blueIdle")
	else:
		anim_sprite.play("redIdle")
	## sprite com machado dependendo da cor
	#if player_id == InputManager.PlayerId.P1:
		#sprite.texture = preload("res://Assets/Personagem/bluex1.png")
	#else:
		#sprite.texture = preload("res://Assets/Personagem/Redx1.png")
	## ajeita a posicao
	#sprite.region_rect = Rect2(10, 31, 42, 19)
	#sprite.offset = Vector2.ZERO

# ------ Area Interacao -------
var bodys_dentro_area := {}
var pos_inicio_interacao : Vector2

func _on_area_interacao_body_entered(body: Node2D) -> void:
	if not bodys_dentro_area.has(body):
		bodys_dentro_area[body] = body
	pos_inicio_interacao = global_position

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if bodys_dentro_area.has(body):
		bodys_dentro_area.erase(body)
