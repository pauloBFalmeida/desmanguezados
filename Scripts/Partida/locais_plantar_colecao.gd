extends Node2D
class_name LocalPlantarColecao

var is_mostrando : bool = false

var animation_nodes : Array[AnimatedSprite2D]

func _ready() -> void:
	for child in get_children():
		var anim : AnimatedSprite2D = child.get_node("AnimatedSprite2D")
		animation_nodes.append(anim)

func add_local_plantar(local_plantar : Node2D) -> void:
	add_child(local_plantar)
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


func esconder() -> void:
	is_mostrando = false
	_update_anim()
func mostrar() -> void:
	is_mostrando = true
	_update_anim()

func _update_anim() -> void:
	if is_mostrando:
		_mostrar()
	else:
		_esconder()

func _esconder() -> void:
	for anim in animation_nodes:
		anim.stop()
		anim.hide()

func _mostrar() -> void:
	var frame_inicio := 0
	# se (lista nao esta vazia) e ja tem animacao visivel em andamento
	if (not animation_nodes.is_empty()) and animation_nodes[0].visible:
		# pega o frame atual como referencia para iniciar as outras
		frame_inicio = animation_nodes[0].frame
		
	for anim in animation_nodes:
		anim.play("default")
		anim.show()
		# sincroniza todas as animacoes
		anim.frame = frame_inicio
