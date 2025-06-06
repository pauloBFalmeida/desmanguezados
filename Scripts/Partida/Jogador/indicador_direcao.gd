extends Node2D
class_name IndicadorDirecao

@export var lerp_speed: float = 5.0 
@export var cor_fora_tracking : Color 
@export var joystick_override : bool = false

@onready var anim : AnimatedSprite2D = $AnimatedSpriteIndicador

var duracao_usar : float

var is_tracking : bool = false
var target_tracking : Node2D = null
@onready var jogador : Node2D = get_parent()

var target_angle : float = 0.0

func _ready() -> void:
	# coloca a animacao padrao
	pronto()
	# ajusta o tempo q leva a animacao
	_set_speed_scale_usar()
	# ao acabar a animacao chama pronto()
	anim.animation_finished.connect(pronto)
	# ajusta para a cor de fora de tracking
	set_tracking(false)

func set_joystick_override(override : bool) -> void:
	# se nao puder dar o override
	if not Configuracoes.possivel_joystick_override:
		joystick_override = false
		return
	
	joystick_override = override
	if joystick_override:
		lerp_speed *= 3
		# ajustar controles de aim
		_ajustar_aim_input_map()

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

func direcao_jogador(dir : Vector2) -> void:
	# se estiver com objeto na area de interacao -> foque no objeto
	if is_tracking or joystick_override: return
	
	# apontar para a direcao do movimento do jogador
	target_angle = dir.angle()

func set_tracking(_is_tracking : bool) -> void:
	is_tracking = _is_tracking
	
	if Configuracoes.indicador_direcao_transparente_sem_target:
		if is_tracking:
			modulate = Color.WHITE
		else:
			modulate = cor_fora_tracking

func set_tracking_target(target : Node2D) -> void:
	target_tracking = target
	
func get_global_position_indicador() -> Vector2:
	return anim.global_position

func _physics_process(delta: float) -> void:
	if joystick_override:
		var aim_dir = Input.get_vector(aim_left, aim_right, aim_up, aim_down)
		if aim_dir.length_squared() > 0.5:
			target_angle = aim_dir.angle()
			#rotation = target_angle
		return
	
	# se nao tiver com objeto na area de interacao -> nao faca mais nada physics
	if not is_tracking: return
	
	var direcao = (target_tracking.global_position - jogador.global_position).normalized()
	target_angle = direcao.angle()

func _process(delta: float) -> void:
	if not is_zero_approx(target_angle - rotation):
		rotation = lerp_angle(rotation, target_angle, lerp_speed * delta)

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
