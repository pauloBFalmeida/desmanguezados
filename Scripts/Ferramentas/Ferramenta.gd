class_name Ferramenta
extends RigidBody2D

@export_flags_2d_physics var layer_acao : int

enum Ferramenta_tipo {CORTAR, PLANTAR, RECOLHER, NONE}

@export var tipo_ferramenta : Ferramenta_tipo

# int da layer [1, 32]
func get_layer_acao() -> int:
	return int(log(layer_acao) / log(2)) + 1

func _ready() -> void:
	add_to_group("Ferramentas")
