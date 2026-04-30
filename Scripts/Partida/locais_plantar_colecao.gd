extends Node2D
class_name LocalPlantarColecao

signal comecou_mostrar
signal plantar(global_pos: Vector2)
signal criado_local_plantar(local_plantar : Node2D)
signal plantado_local_plantar(local_plantar : Node2D)

var is_mostrando : bool = false

var animation_nodes : Array[AnimatedSprite2D]

func _ready() -> void:
	for child in get_children():
		if child.is_in_group("LocalPlantar"):
			var anim : AnimatedSprite2D = child.get_node("AnimatedSprite2D")
			animation_nodes.append(anim)

# --------------
# Plantar
# --------------
func plantar_muda(local_plantar : Node2D) -> void:
	var global_pos := local_plantar.global_position
	emit_signal("plantar", global_pos)
	emit_signal("plantado_local_plantar", local_plantar)
	remove_local_plantar(local_plantar)

# --------------
# local_plantar
# --------------
func add_local_plantar(local_plantar : Node2D) -> void:
	add_child(local_plantar)
	emit_signal("criado_local_plantar", local_plantar)
	var anim : AnimatedSprite2D = local_plantar.get_node("AnimatedSprite2D")
	animation_nodes.append(anim)
	_update_anim()
	

func remove_local_plantar(local_plantar : Node2D) -> void:
	# remove da lista
	var anim : AnimatedSprite2D = local_plantar.get_node("AnimatedSprite2D")
	animation_nodes.erase(anim)
	# retira do jogo
	local_plantar.hide()
	local_plantar.queue_free()

# --------------
# Mostrar e Esconder
# --------------
func esconder() -> void:
	is_mostrando = false
	_update_anim()

func mostrar() -> void:
	is_mostrando = true
	_update_anim()
	emit_signal("comecou_mostrar") 

func _update_anim() -> void:
	if is_mostrando:
		_mostrar()
	else:
		_esconder()

func _esconder() -> void:
	for anim in animation_nodes:
		# meh fix para problema de internet
		if is_instance_valid(anim):
			anim.stop()
			anim.hide()

func _mostrar() -> void:
	# se a lista nao esta vazia, pare
	if animation_nodes.is_empty(): return
	
	# frame para igual todos
	var frame_sync : int = -1
	
	for anim in animation_nodes:
		if is_instance_valid(anim):
			# se nao tem um frame de referencia ainda, pegue da primeira anim valida
			if frame_sync < 0:
				# pega o frame atual como referencia para sincronizar com as outras anim
				frame_sync = anim.frame
			# play animacao
			anim.play("default")
			anim.show()
			# sincroniza todas as animacoes
			anim.frame = frame_sync
