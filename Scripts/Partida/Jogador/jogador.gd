extends CharacterBody2D
class_name Jogador

@export var player_id := InputManager.PlayerId.P1
var is_usando_controle : bool = false

@export var theme_color : Color

## velocidade do jogador
@export var speed: float = 250.0
## porcentagem de slowdown durante o cooldown de usar uma ferramenta
@export var slowdown_cooldown: float = 0.2
## porcentagem de slowdown no lodo
@export var slowdown_lodo: float = 0.75
var speed_modifier_terreno : float = 1.0
var speed_modifier_cooldown : float = 1.0


## segundos que pode ficar na agua ate morrer
@export var max_water_time := 0.8
var curr_water_timer := 0.0 # tempo atual que esta dentro a agua
var is_on_water : bool = false

@onready var spawn_jogadores : SpawnJogadores = $".."
var ferramentas_mgmt : FerramentaMgmt

@onready var area_interacao : Area2D = $AreaInteracao
@onready var anim_sprite := $AnimatedSprite2D
@onready var sombra_sprite := $SpriteSombra

@onready var indicador_direcao : IndicadorDirecao = $IndicadorDirecao
# ultima direcao que o jogador deu input de movimento
var last_input_movimento := Vector2.RIGHT

@onready var instrucoes := $IntrucoesUI
@onready var instrucoes_label := $IntrucoesUI/LabelInstrucoes
var mostrar_instrucoes := false

const collision_layer_ferramentas : int = 3
var ferramenta_collision_mask : int

var segurando : Ferramenta = null

@export var throw_max_hold_sec : float = 3.0
@export var throw_min_hold_sec : float = 0.45
var throw_acumulado_sec : float = 0
var is_throw_cancelado = false
@onready var throw_max_hold_sec_div : float = 1 / throw_max_hold_sec

# -- Input --
var move_left: StringName
var move_right: StringName
var move_up: StringName
var move_down: StringName
var interact: StringName
var pickup: StringName
var drop: StringName

func _ready() -> void:
	#
	ferramentas_mgmt = spawn_jogadores.get_ferramentas_mgmt()
	#
	_ajustar_input_map()
	is_usando_controle = InputManager.players_no_controle.has(player_id) # marca se o jogador esta no controle
	indicador_direcao.set_joystick_override(is_usando_controle)
	# ajusta o nome
	var nome_id : String = "P1" if player_id == InputManager.PlayerId.P1 else "P2"
	set_name('Jogador_' + nome_id)
	# coloca o personagem no idle -> para ajustar a cor
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
	pickup     = actionMap["pickup"]
	drop       = actionMap["drop"]

var prev_pos := Vector2.ONE
func _physics_process(_delta: float) -> void:
	# ---- lidar com button presses ----
	if Input.is_action_just_pressed(interact):
		_throw_ferramenta_cancelar() # cancela jogar ferramenta
		interagir()
	if Input.is_action_just_pressed(pickup):
		_throw_ferramenta_cancelar() # cancela jogar ferramenta
		lidar_pickup()
	
	# lidar com esta na agua queue se necessario
	if use_set_on_water_queue: _lidar_set_on_water()
	# sombra
	sombra_sprite.visible = not is_on_water
	
	# ---- indicador de direcao ----
	if indicador_direcao.is_tracking:
		indicador_direcao.set_tracking_target(body_mais_desejado_interacao())
	

func _process(delta: float) -> void:
	var move_dir = Input.get_vector(move_left, move_right, move_up, move_down)
	
	velocity = move_dir * speed * speed_modifier_terreno * speed_modifier_cooldown
	move_and_slide()
	
	if Input.is_action_just_released(drop):
		_throw_ferramenta_jogar()
	
	if Input.is_action_pressed(drop):
		_throw_ferramenta_segurando(delta)
	else:
		# largou o botao, reset o throw
		is_throw_cancelado = false
	
	# -- lidar com estar na agua --
	if is_on_water:
		curr_water_timer += delta
	else:
		curr_water_timer = 0
	lidar_agua()
	
	# update o indicador de direcao
	if not move_dir.is_zero_approx(): # se o player deu input de mover
		# salva essa direcao
		last_input_movimento = move_dir
		# update da direcao do jogador pro indicador de direcao
		indicador_direcao.direcao_jogador( move_dir )

# ----------------------------------------------
# Set de atributos
# ----------------------------------------------
func set_speed_modifier_terreno(_speed_modifier_lodo : float) -> void:
	speed_modifier_terreno = slowdown_lodo * _speed_modifier_lodo

# ----------------------------------------------
# Lidar com o contato com agua
# ----------------------------------------------
## so usar queue se tiver mais de um water source
var use_set_on_water_queue : bool = false 
var _set_on_water_queue : Array[bool] = []

func set_on_water(_on_water : bool) -> void:
	if not use_set_on_water_queue:
		is_on_water = _on_water
		return
	# se for para usar a queue
	_set_on_water_queue.append(_on_water)
	
func _lidar_set_on_water() -> void:
	is_on_water = _set_on_water_queue.any(func(x): return x)
	clear_set_on_water_queue()

func clear_set_on_water_queue() -> void:
	_set_on_water_queue.clear()

func lidar_agua() -> void:
	const color_base = Color.WHITE
	var color_fade = Color.DARK_SLATE_GRAY
	color_fade.a = 0.4
	# se nao esta na agua
	if is_zero_approx(curr_water_timer):
		modulate = color_base
		return
	
	if curr_water_timer >= max_water_time:
		spawn_jogadores.respawn_jogador(self)
	
	# limite
	var weight = curr_water_timer / max_water_time
	# deixa mais transparente
	modulate = lerp(color_base, color_fade, weight)

# ----------------------------------------------
# Instrucoes
# ----------------------------------------------
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
	if is_usando_controle:
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
	if is_usando_controle:
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
	if is_usando_controle:
		if player_id == InputManager.PlayerId.P1:
			txt_botao = Configuracoes.string_pegar_controle_P1
		else:
			txt_botao = Configuracoes.string_pegar_controle_P2
	else:
		txt_botao = "Espaço"
		
	instrucoes_label.text = txt_botao + " para largar"

# ----------------------------------------------
# Interagir
# ----------------------------------------------
func interagir() -> void:	
	# se nao tiver nada na area -> nao faca nada
	if bodys_dentro_area.is_empty():
		balancar_ferramenta()
		return
	
	# pega o body dentro da area que eh o mais desejado
	var body : Node2D = body_mais_desejado_interacao("Marcador")
	# -- fazemos a acao sobre o corpo --
	# se for alvo da ferramenta -> usar ferramenta
	if body.is_in_group("Marcador"):
		mostrar_instrucoes_usar()
		usar_ferramenta(body)

# ----------------------------------------------
# Usar, Balancar ferramenta
# ----------------------------------------------
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

# ----------------------------------------------
# Pegar, Largar e Jogar Ferramentas
# ----------------------------------------------
# ------ Lidar com o pickup -------
func lidar_pickup() -> void:
	# se n tem o que pegar dentro da area de interacao -> nao pode pegar nada
	if bodys_dentro_area.is_empty(): return
	
	# pega uma ferramenta dentro do range de interacao
	var body : Node2D = body_mais_desejado_interacao("Ferramentas")
	# nao tem ferramenta dentro do range -> nao pode pegar nada
	if not body.is_in_group("Ferramentas"): return
	
	var ferramenta : Ferramenta = body
	
	# se ja estiver segurando uma ferramenta
	if segurando and is_instance_valid(segurando):
		# drop a ferramenta que esta segurando, no local que estava a no chao
		drop_ferramenta(ferramenta.global_position)
	
	# mostrar intrucoes
	mostrar_instrucoes_pegar()
	
	# pega a ferramenta do chao
	pegar_ferramenta(ferramenta)

# ------ Pegar -------
func pegar_ferramenta(ferramenta : Ferramenta) -> void:
	# se ja estiver segurando uma ferramenta -> nao faca nada
	if segurando and is_instance_valid(segurando): return
	
	segurando = ferramenta
	ferramentas_mgmt.jogador_pegar_ferramenta(self, ferramenta)
	
	# ajusta para a area de interacao reconhecer o alvo da ferramenta
	ferramenta_collision_mask = ferramenta.get_layer_acao()
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, true)
	# ==> versao atual da pra trocar de ferramenta sem dropar, entao essa parte esta off <==
	# remove a layer das ferramentas 
	#area_interacao.set_collision_mask_value(collision_layer_ferramentas, false)
	
	# anim pegar a ferramenta
	anim_segurar_ferramenta(segurando)
	
	# remove a ferramenta dos bodies dentro da area de interacao do jogador
	bodys_dentro_area.erase(ferramenta)
	
	# atualiza o indicador de direcao (necessario)
	_update_indicador_direcao_interacao()

# ------ Dropar -------
func drop_ferramenta(global_pos_ferramenta := Vector2.ZERO) -> void:
	# se n tiver segurando nenhuma ferramenta -> nao faca nada
	if (not segurando) or (not is_instance_valid(segurando)): return
	
	var ferramenta : Ferramenta = segurando
	
	ferramentas_mgmt.jogador_dropar_ferramenta(self, ferramenta, global_pos_ferramenta)
	_limpar_jogador_ferramenta(ferramenta)

func _limpar_jogador_ferramenta(ferramenta : Ferramenta) -> void:
	# limpa a mao
	segurando = null
	
	# area de interacao nao reconhece mais o alvo da ferramenta
	area_interacao.set_collision_mask_value(ferramenta_collision_mask, false)
	ferramenta_collision_mask = 32 # ajusta pra outro valor
	# ativa a layer das ferramentas 
	area_interacao.set_collision_mask_value(collision_layer_ferramentas, true)
	
	anim_idle()

# ---- Jogar da ferramenta ----
func _throw_ferramenta_segurando(delta : float) -> void:
	# se nao estiver segurando nada -> nao faca nada
	if (not segurando) or (not is_instance_valid(segurando)): 
		return
	# se o throw foi cancelado, mas o botao ainda esta sendo segurado -> nao faca nada
	if is_throw_cancelado:
		return
	
	# adiciona o tempo do frame no acumulado
	throw_acumulado_sec += delta
	# limite no valor maximo
	throw_acumulado_sec = min(throw_acumulado_sec, throw_max_hold_sec)
	# menos do que o minimo -> nao mostre nada
	if throw_acumulado_sec < throw_min_hold_sec:
		return
	
	# direcao para jogar
	var direcao := indicador_direcao.get_direcao()
	# update a curva de jogar a ferramenta
	var charge := throw_acumulado_sec * throw_max_hold_sec_div
	ferramentas_mgmt.jogador_throw_ferramenta_segurando(self, direcao, charge)

func _throw_ferramenta_jogar() -> void:
	# se nao estiver segurando nada -> nao faca nada
	if (not segurando) or (not is_instance_valid(segurando)): 
		return
	# se foi cancelado -> nao jogue a ferramenta
	if is_throw_cancelado:
		return
	
	# menos do que o minimo -> so largue
	if throw_acumulado_sec < throw_min_hold_sec:
		drop_ferramenta()
		return
	
	# jogue a ferramenta
	ferramentas_mgmt.jogador_throw_ferramenta_jogar(self, segurando)
	# jogador parar de segurar ferramenta
	_limpar_jogador_ferramenta(segurando)
	
	# reset dps de jogar
	_throw_ferramenta_reset()

func _throw_ferramenta_cancelar() -> void:
	is_throw_cancelado = true
	_throw_ferramenta_reset()
	# limpa a curva prevista da memoria
	ferramentas_mgmt.jogador_throw_limpar_predicao(self)

func _throw_ferramenta_reset() -> void:
	throw_acumulado_sec = 0


# ----------------------------------------------
# Cooldown da ferramenta
# ----------------------------------------------
var ja_tem_anim_cooldown : bool = false

func cooldown_jogador(ferramenta : Ferramenta) -> void:
	# se ja tiver rodando o cooldown
	if ja_tem_anim_cooldown: return
	# marca que esta aplicando o cooldown
	ja_tem_anim_cooldown = true
	
	# slow 
	speed_modifier_cooldown = slowdown_cooldown
	
	# animacao de cooldown
	var duracao := ferramenta.duracao_cooldown
	indicador_direcao.comecar_cooldown(duracao)
	get_tree().create_timer(duracao).timeout.connect( _fim_cooldown_jogador )

func _fim_cooldown_jogador() -> void:
	ja_tem_anim_cooldown = false
	speed_modifier_cooldown = 1.0 # retira o slow do cooldown

# ----------------------------------------------
# Animacao
# ----------------------------------------------
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

# ----------------------------------------------
# indicador de direcao
# ----------------------------------------------
func body_mais_desejado_interacao(group_desejado : String = "") -> Node2D:
	if bodys_dentro_area.is_empty(): return null
	
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
			# se tiver um grupo desejado and _body nao esta nesse grupo
			if (not group_desejado.is_empty()) and (not _body.is_in_group(group_desejado)):
				dist += 100000 # valor alto para deixar ele menos atrativo
			# se grupo desejado nao for Ferramentas -> deixar ferramentas menos atrativas
			if (_body.is_in_group("Ferramenta") and group_desejado != "Ferramenta"):
				dist += 10000 # valor medio para deixar ele menos atrativo
			
			# se atual for menor do q o temos marcado -> vira o marcado
			if dist < min_dist:
				min_dist = dist
				min_body = _body
		return min_body
	# nao deve cair aqui :p
	return null

func _update_indicador_direcao_interacao() -> void:
	# nao tem nada para interagir perto
	if bodys_dentro_area.is_empty():
		# desativa o tracking
		indicador_direcao.set_tracking(false)
	else:
		# se tiver algo -> vira alvo do tracking 
		indicador_direcao.set_tracking(true)
		indicador_direcao.set_tracking_target(body_mais_desejado_interacao())

# ----------------------------------------------
# Area Interacao
# ----------------------------------------------
var bodys_dentro_area := {}
func _on_area_interacao_body_entered(body: Node2D) -> void:
	if not bodys_dentro_area.has(body):
		bodys_dentro_area[body] = body
	_update_indicador_direcao_interacao()

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if bodys_dentro_area.has(body):
		bodys_dentro_area.erase(body)
	_update_indicador_direcao_interacao()
