class_name Ferramenta
extends CharacterBody2D

enum Ferramenta_tipo {CORTAR, PLANTAR, RECOLHER}
enum Som_tipo {ACERTO, ERRO, BALANCAR}

@export_flags_2d_physics var layer_acao : int
@export var tipo_ferramenta : Ferramenta_tipo
## em segundos
@export var duracao_cooldown : float = 0.5
@export var sons : Dictionary[Som_tipo, AudioStream]

var collison : CollisionShape2D
var audio_player : AudioStreamPlayer2D
var sprite : Sprite2D

var ferramenta_mgmt : FerramentaMgmt
var is_on_cooldown : bool = false

var shader_mat : ShaderMaterial
var base_thickness : float

# int da layer [1, 32]
func get_layer_acao() -> int:
	return int(log(layer_acao) / log(2)) + 1

func _ready() -> void:
	add_to_group("Ferramentas")
	collison = get_node("CollisionShape2D")
	audio_player = get_node("AudioStreamPlayer2D")
	sprite = get_node("Sprite2D")
	# 
	_ajustar_outline()


func _ajustar_outline() -> void:
	# duplica o material
	var original_material := sprite.material as ShaderMaterial
	var new_material := original_material.duplicate() as ShaderMaterial
	sprite.material = new_material
	shader_mat = new_material
	# salva a base thickness
	base_thickness = new_material.get_shader_parameter("thickness")

func outline_on() -> void:
	shader_mat.set_shader_parameter("thickness", base_thickness)
func outline_off() -> void:
	shader_mat.set_shader_parameter("thickness", 0.0)

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

func set_ferramenta_mgmt(fer_mgmt : FerramentaMgmt) -> void:
	ferramenta_mgmt = fer_mgmt

# -- som --
func tocar_som(tipo_som : Som_tipo) -> void:	
	audio_player.set_stream(sons[tipo_som])
	audio_player.play()
	
	#match tipo_som:
		#Som_tipo.ACERTO:
		#Som_tipo.ERRO:
		#Som_tipo.BALANCAR:

func balancar_ferramenta() -> void:
	# nao deixa spammar balancar (usar ferramenta sem ser em algo)
	if audio_player.playing:
		return
	tocar_som(Som_tipo.BALANCAR)

# -- Cooldown --
func aplicar_cooldown() -> void:
	is_on_cooldown = true
	get_tree().create_timer(duracao_cooldown).timeout.connect(_terminar_cooldown)

func _terminar_cooldown() -> void:
	is_on_cooldown = false

# --- Abstrato ---
func usar_ferramenta(_body : Node2D) -> void:
	pass
