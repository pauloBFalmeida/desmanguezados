class_name Ferramenta
extends RigidBody2D

@export_flags_2d_physics var layer_acao : int

enum Ferramenta_tipo {CORTAR, PLANTAR, RECOLHER, NONE}

@export var tipo_ferramenta : Ferramenta_tipo

@onready var collison := get_node("CollisionShape2D")

# int da layer [1, 32]
func get_layer_acao() -> int:
	return int(log(layer_acao) / log(2)) + 1

func _ready() -> void:
	add_to_group("Ferramentas")

func hide_ferramenta() -> void:
	visible = false
	set_physics_process(false)
	set_process(false)
	collison.disabled = true

func show_ferramenta() -> void:
	visible = true
	set_physics_process(true)
	set_process(true)
	collison.disabled = false

# --- Abstrato ---
func usar_ferramenta(body : Node2D) -> void:
	pass
	#match (tipo):
		#Ferramenta.Ferramenta_tipo.CORTAR:
			##TODO: Cortar arvore
			#var tween = create_tween()
			#tween.set_ease(Tween.EASE_IN)
			#tween.tween_property(body, "modulate:a", 0.3, 0.2)
			#tween.finished.connect(func():
				#var tween2 = create_tween()
				#tween2.set_ease(Tween.EASE_OUT)
				#tween2.tween_property(body, "modulate:a", 1.0, 0.2)
			#)
		#Ferramenta.Ferramenta_tipo.PLANTAR:
			#pass
		#Ferramenta.Ferramenta_tipo.RECOLHER:
			#var lixo = body
			#var tween = create_tween()
			#tween.set_ease(Tween.EASE_IN)
			#tween.tween_property(lixo, "modulate:a", 0.0, 0.5).from_current()
			#tween.finished.connect( func():
				#lixo.queue_free() ### TODO fix this
			#)
