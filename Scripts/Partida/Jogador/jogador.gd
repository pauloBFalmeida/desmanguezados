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
@onready var indicador_direcao := $IndicadorDirecao

@onready var instrucoes := $IntrucoesUI
@onready var instrucoes_label := $IntrucoesUI/LabelInstrucoes
var mostrar_instrucoes := false

const collision_layer_ferramentas : int = 3

var segurando : Ferramenta = null

var ferramenta_collision_mask : int

var speed_modifier_terreno : float = 1.0
var speed_modifier_cooldown : float = 1.0

# ultima direcao que o jogador deu input de movimento
var last_input_movimento := Vector2.RIGHT

# -- Input --
var move_left: StringName
var move_right: StringName
var move_up: StringName
var move_down: StringName
var interact: StringName
var drop: StringName

var no_controle : bool = false

func _ready() -> void:
	_ajustar_input_map()
	no_controle = InputManager.players_no_controle.has(player_id) # marca se o jogador esta no controle
	indicador_direcao.set_joystick_override(no_controle)
	# ajusta o nome
	var nome_id : String = "P1" if player_id == InputManager.PlayerId.P1 else "P2"
	set_name('Jogador_' + nome_id)
	# ajeita o sprite
	anim_idle()
	# 
	#instrucoes.hide()

func _ajustar_input_map() -> void:
	# ajusta o action map do player
	var actionMap : Dictionary = InputManager.actionMap_players[player_id]
	
	move_left  = actionMap["move_left"]
	move_right = actionMap["move_right"]
	move_up    = actionMap["move_up"]
	move_down  = actionMap["move_down"]
	interact   = actionMap["interact"]
	drop       = actionMap["drop"]

var prev_pos := Vector2.ONE
func _physics_process(_delta: float) -> void:
	# ---- indicador de direcao ----
	if indicador_direcao.is_tracking:
		indicador_direcao.set_tracking_target(body_mais_desejado_interacao())
	
	# ---- slow down do terreno ----
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
	
	# update o indicador de direcao
	if not move_dir.is_zero_approx(): # se o player deu input de mover
		# salva essa direcao
		last_input_movimento = move_dir
		# update da direcao do jogador pro indicador de direcao
		indicador_direcao.direcao_jogador( move_dir )
			

# ------ Acao -------
func acao() -> void:	
	# se nao tiver nada na area -> nao faca nada
	if bodys_dentro_area.is_empty():
		balancar_ferramenta()
		return
	
	# pega o body dentro da area que eh o mais desejado
	var body : Node2D = body_mais_desejado_interacao()
	# fazemos a acao sobre o corpo
	if body.is_in_group("Ferramentas"):
		mostrar_instrucoes_pegar()
		pegar_ferramenta(body)
	elif body.is_in_group("Marcador"):
		mostrar_instrucoes_usar()
		usar_ferramenta(body)
	else:
		print('body escolhido: ', body)

# ==== ?????
var primeira_vez : bool = true

func mostrar_instrucoes_pegar() -> void:
	if not mostrar_instrucoes: return
	
	
	instrucoes.show()
	get_tree().create_timer(2.0).timeout.connect(
		func(): instrucoes.hide()
	)
	
	if primeira_vez:
		primeira_vez = false
		get_tree().create_timer(3.0).timeout.connect(
			mostrar_instrucoes_drop
		)
	
	
	var txt_botao : String
	if no_controle:
		if player_id == InputManager.PlayerId.P1:
			txt_botao = Configuracoes.string_pegar_controle_P1
		else:
			txt_botao = Configuracoes.string_pegar_controle_P2
	else:
		txt_botao = "Espaço"
		
	instrucoes_label.text = txt_botao + " para pegar"

func mostrar_instrucoes_usar() -> void:
	if not mostrar_instrucoes: return
	
	instrucoes.show()
	get_tree().create_timer(2.0).timeout.connect(
		func(): instrucoes.hide()
	)
	
	var txt_botao : String
	if no_controle:
		if player_id == InputManager.PlayerId.P1:
			txt_botao = Configuracoes.string_pegar_controle_P1
		else:
			txt_botao = Configuracoes.string_pegar_controle_P2
	else:
		txt_botao = "Espaço"
		
	instrucoes_label.text = txt_botao + " para usar"

func mostrar_instrucoes_drop() -> void:
	if not mostrar_instrucoes: return
	
	instrucoes.show()
	get_tree().create_timer(2.0).timeout.connect(
		func(): instrucoes.hide()
	)
	
	var txt_botao : String
	if no_controle:
		if player_id == InputManager.PlayerId.P1:
			txt_botao = Configuracoes.string_pegar_controle_P1
		else:
			txt_botao = Configuracoes.string_pegar_controle_P2
	else:
		txt_botao = "Espaço"
		
	instrucoes_label.text = txt_botao + " para largar"

func body_mais_desejado_interacao() -> Node2D:
	# so 1 body dentro -> pega esse
	if bodys_dentro_area.size() == 1:
		for _body in bodys_dentro_area.values():
			return _body
	# mais de 1 body dentro -> pega o mais proximo da direcao do movimento
	else:
		var prox_posicao : Vector2
		if indicador_direcao.joystick_override:
			# se tiver o override do joystick -> pegar a posicao do indicador
			prox_posicao = indicador_direcao.get_global_position_indicador()
		else:
			# extrapolacao da posicao global que o jogador "esta" se movendo
			var direcao : Vector2 = last_input_movimento.normalized()
			prox_posicao = global_position + direcao 
		
		# acha o body mais proximo de "prox_posicao"
		var min_dist : float = INF
		var min_body : Node2D = null
		for _body : Node2D in bodys_dentro_area.values():
			var dist = _body.global_position.distance_squared_to(prox_posicao)
			# se atual for menor do q o temos marcado -> vira o marcado
			if dist < min_dist:
				min_dist = dist
				min_body = _body
		return min_body
	# nao deve cair aqui :p
	return null

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
	# remove a layer das ferramentas 
	area_interacao.set_collision_mask_value(collision_layer_ferramentas, false)
	
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
	ferramenta_collision_mask = 32 # ajusta pra outro valor
	# retorna a layer das ferramentas 
	area_interacao.set_collision_mask_value(collision_layer_ferramentas, true)
	
	anim_idle()	

# ---- Cooldown da ferramenta ----
var ja_tem_anim_cooldown : bool = false

func cooldown_jogador(ferramenta : Ferramenta) -> void:
	# se ja tiver rodando o cooldown
	if ja_tem_anim_cooldown: return
	# marca que esta aplicando o cooldown
	ja_tem_anim_cooldown = true
	
	# slow 
	speed_modifier_cooldown = 0.2
	
	# animacao de cooldown
	var duracao := ferramenta.duracao_cooldown
	indicador_direcao.comecar_cooldown(duracao)
	get_tree().create_timer(duracao).timeout.connect( _fim_cooldown_jogador )

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
			else:
				anim_sprite.play("redCortar")
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

func _update_indicador_direcao_interacao() -> void:
	if bodys_dentro_area.is_empty():
		indicador_direcao.set_tracking(false)
	else:
		indicador_direcao.set_tracking(true)
		indicador_direcao.set_tracking_target(body_mais_desejado_interacao())

# ------ Area Interacao -------
var bodys_dentro_area := {}
func _on_area_interacao_body_entered(body: Node2D) -> void:
	if not bodys_dentro_area.has(body):
		bodys_dentro_area[body] = body
	_update_indicador_direcao_interacao()

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if bodys_dentro_area.has(body):
		bodys_dentro_area.erase(body)
	_update_indicador_direcao_interacao()
