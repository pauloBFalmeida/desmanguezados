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


func receber_hit(direcao : Vector2, forca : float) -> void:
	apply_impulse(direcao * forca)


func get_dados() -> Dictionary:
	var dados : Dictionary = {
		"texto": label_texto.text,
		"peso" : mass,
		"font_size" : label_texto.get_theme_font_size("normal_font_size"),
		"font_color": label_texto.get_theme_color("normal_font_size"),
	}
	return dados

func set_dados(dados : Dictionary) -> void:
	label_texto.text = dados["texto"]
	mass = dados["peso"]
	label_texto.add_theme_font_size_override("normal_font_size", dados["font_size"])
	label_texto.add_theme_color_override("normal_font_size", dados["font_color"])
