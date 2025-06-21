extends RigidBody2D
class_name TextoCreditos

signal hit

## distancia minima do spawn para poder spawnar outro
@export var min_distance_spawn : float = 100.0
@onready var min_distance_spawn_sqrd := min_distance_spawn * min_distance_spawn

@onready var label_texto := $Label
@onready var collision := $CollisionShape2D

var was_hit : bool = false
var start_global_pos : Vector2

func _ready() -> void:
	start_global_pos = global_position

# se mudou de posicao (mais que o minimo) -> foi acertado
func _physics_process(delta: float) -> void:
	if global_position.distance_squared_to(start_global_pos) > min_distance_spawn_sqrd:
		if not was_hit:
			was_hit = true
			emit_signal("hit")

func get_texto() -> String:
	return label_texto.text

func set_texto(texto : String) -> void:
	label_texto.text = texto

func get_label() -> Label:
	return label_texto

func toggle_collision(_on : bool) -> void:
	collision.disabled = not _on

func colocar_global_pos(global_pos : Vector2) -> void:
	#var body_state := PhysicsDirectBodyState2D.new()
	#body_state.transform
	pass

func receber_hit(direcao : Vector2, forca : float) -> void:
	apply_impulse(direcao * forca)
