extends Level

@export var max_distance_target : float = 50.0
@export var camera_lerp_speed_curve: Curve
@export var camera_lerp_speed: float = 3.0
@export var camera_target : Node2D
@onready var camera := $Camera2D

@onready var jogadores := $SpawnJogadores.get_children()

@onready var screen_center : Vector2 = camera.global_position
@onready var screen_center_length : float = screen_center.length()

func _ready() -> void:
	super()
	print("Level Zen")
	temporizador.parar() # para de contar o tempo
	# lidar com a quantidade de jogadores
	if Globais.modo_zen_ter_1_jogador:
		for jog in jogadores:
			if jog != camera_target:
				jog.global_position = Vector2(-999, -999)
				jog.hide()
				jog.set_physics_process(false)
				jog.set_process(false)
				jog.set_process_input(false)
	
	#gerar_mapa_aleatorio()

var position_target : Vector2 = Vector2.ZERO
var dist_out_cam : float = 0.0

func _process(delta: float) -> void:
	var direcao : Vector2 = camera_target.global_position - camera.global_position
	if direcao.length() > max_distance_target:
		var dist = direcao.length() / screen_center_length
		var weight : float = camera_lerp_speed_curve.sample(dist) * camera_lerp_speed
		camera.global_position = lerp(camera.global_position,
									camera_target.global_position, 
									weight * delta)

@onready var tilemap_areia := $TileMaps/TileMapDualAreia

func gerar_mapa_aleatorio() -> void:
	var tile_coords = Vector2i(1,1)
	tilemap_areia.set_cell(tile_coords, 1, Vector2i(2,1), 0)
