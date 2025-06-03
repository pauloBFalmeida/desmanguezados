class_name Ferramenta
extends RigidBody2D

enum Ferramenta_tipo {CORTAR, PLANTAR, RECOLHER}
enum Som_tipo {ACERTO, ERRO, BALANCAR}

@export_flags_2d_physics var layer_acao : int
@export var tipo_ferramenta : Ferramenta_tipo
@export var sons : Dictionary[Som_tipo, AudioStream]

var collison : CollisionShape2D
var audio_player : AudioStreamPlayer2D


# int da layer [1, 32]
func get_layer_acao() -> int:
	return int(log(layer_acao) / log(2)) + 1

func _ready() -> void:
	add_to_group("Ferramentas")
	collison = get_node("CollisionShape2D")
	audio_player = get_node("AudioStreamPlayer2D")

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

# -- som --
func tocar_som(tipo_som : Som_tipo) -> void:
	audio_player.set_stream(sons[tipo_som])
	#audio_player.play()
	
	#match tipo_som:
		#Som_tipo.ACERTO:
		#Som_tipo.ERRO:
		#Som_tipo.BALANCAR:

func balancar_ferramenta() -> void:
	tocar_som(Som_tipo.BALANCAR)

# --- Abstrato ---
func usar_ferramenta(_body : Node2D) -> void:
	pass
