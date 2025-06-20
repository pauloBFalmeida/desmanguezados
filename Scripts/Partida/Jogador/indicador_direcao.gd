extends Node2D
class_name IndicadorDirecao

@export var lerp_speed: float = 5.0 
@export var cor_fora_tracking : Color 
var joystick_override : bool = false
var is_manual_aim : bool = false

@onready var jogador : Jogador = get_parent()
@onready var anim : AnimatedSprite2D = $AnimatedSpriteIndicador

var duracao_usar : float

var is_tracking : bool = false
var target_tracking : Node2D = null


var target_angle : float = 0.0

func _ready() -> void:
	_ajustar_animacao()
	# ajusta para a cor de fora de tracking
	set_tracking(false)

func _physics_process(_delta: float) -> void:
	# se (for joystick override) ou (auto aim estiver off) -> pegar o input do player
	if joystick_override or is_manual_aim:
		_get_player_aim()
		return
	
	# se nao tiver com objeto na area de interacao -> nao faca mais nada physics
	if not is_tracking: return
	
	var direcao = (target_tracking.global_position - jogador.global_position).normalized()
	target_angle = direcao.angle()

func _process(delta: float) -> void:
	# move o indicador gentilmente
	if not is_zero_approx(target_angle - rotation):
		rotation = lerp_angle(rotation, target_angle, lerp_speed * delta)

# ---------------------------
# Setters
# ---------------------------
func set_manual_aim(is_manual : bool) -> void:
	is_manual_aim = is_manual

func set_usando_joystick(is_usando : bool) -> void:
	# se nao estiver usando controle -> nao mude nada
	if not is_usando: return
	
	# pega a configuracao se eh full override
	joystick_override = Configuracoes.possivel_joystick_override
	
	lerp_speed *= 3
	# ajustar controles de aim
	_ajustar_aim_input_map()

# --- Tracking ---
func set_tracking(_is_tracking : bool) -> void:
	is_tracking = _is_tracking
	# muda a direcao se for necessario
	if Configuracoes.indicador_direcao_transparente_sem_target:
		if is_tracking:
			modulate = Color.WHITE
		else:
			modulate = cor_fora_tracking

func set_tracking_target(target : Node2D) -> void:
	target_tracking = target

# ---------------------------
# Getters
# ---------------------------
func get_global_position_indicador() -> Vector2:
	return anim.global_position

func get_direcao() -> Vector2:
	var dir := get_global_position_indicador() - jogador.global_position
	return dir.normalized()

# ---------------------------
# Direcao do jogador
# ---------------------------
func direcao_jogador(dir : Vector2) -> void:
	# se estiver com objeto na area de interacao -> foque no objeto
	# se estiver com full override, ou estiver com auto aim desligado
	if is_manual_aim or is_tracking or joystick_override: return
	
	# apontar para a direcao do movimento do jogador
	target_angle = dir.angle()

# ---------------------------
# Input Map
# ---------------------------
var aim_left: StringName
var aim_right: StringName
var aim_up: StringName
var aim_down: StringName
func _ajustar_aim_input_map() -> void:
	var actionMap : Dictionary = InputManager.actionMap_players[jogador.player_id]
	aim_left  = actionMap["aim_left"]
	aim_right = actionMap["aim_right"]
	aim_up    = actionMap["aim_up"]
	aim_down  = actionMap["aim_down"]

# ---------------------------
# Animacao
# ---------------------------
func _ajustar_animacao() -> void:
	# coloca a animacao padrao
	pronto()
	# ajusta o tempo q leva a animacao
	_set_speed_scale_usar()
	# ao acabar a animacao chama pronto()
	anim.animation_finished.connect(pronto)

func _get_player_aim() -> void:
	# jogador com controle
	if jogador.is_usando_controle:
		var aim_dir = Input.get_vector(aim_left, aim_right, aim_up, aim_down)
		if aim_dir.length_squared() > 0.5:
			target_angle = aim_dir.angle()
			#rotation = target_angle
	else: # mouse teclado
		var mouse_pos := get_viewport().get_mouse_position()
		# direcao do jogador para o mouse
		var direcao := mouse_pos - jogador.global_position
		direcao = direcao.normalized()
		var angulo : float = direcao.angle()
		target_angle = angulo

func _set_speed_scale_usar() -> void:
	const animation_name := "usar"
	var animation_frames := anim.get_sprite_frames()
	var contagem := animation_frames.get_frame_count(animation_name)
	
	var duracao : float = 0.0
	for i in range(contagem):
		duracao += animation_frames.get_frame_duration(animation_name, i)
	
	var fps = animation_frames.get_animation_speed(animation_name)
	
	# ajusta a global
	duracao_usar = duracao * fps

func comecar_cooldown(duracao_cooldown : float) -> void:
	const animation_name := "usar"
	# speed_scale -> multiplicacao de velocidade que vai tocar a animacao
	# qtd frames  * fps = duracao_cooldown * speed_scale
	# speed_scale = (qtd frames  * fps) / duracao_cooldown
	# 5				 7.5         1.0s  / 1.5s *	
	var speed_scale : float = duracao_usar / duracao_cooldown
	
	# comeca a animacao
	anim.play(animation_name, speed_scale)

func pronto() -> void:
	anim.play("default")
