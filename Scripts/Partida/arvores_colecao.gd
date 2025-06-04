extends CanvasGroup
class_name ArvoresColecao

@onready var shader_material := material

#var objetos_atras : Array[Node2D]

var arvores_filhas : Dictionary[Arvore, Arvore]

func update_arvores() -> void:
	for arvore : Arvore in get_children():
		if not arvores_filhas.has(arvore):
			arvores_filhas[arvore] = arvore
			var area_atencao : Area2D = arvore.get_node("Area2DMostrarBuraco")
			area_atencao.body_entered.connect(_add_body_atencao)
			area_atencao.body_exited.connect(_rem_body_atencao)

func _process(_delta):
	pass
	#var world_positions = []
	#
	#for obj in objetos_atras:
		#world_positions.append(obj.global_position)
	#
	#
	#shader_material.set_shader_parameter("sprite_world_position", get_children()[0].global_position)
	#shader_material.set_shader_parameter("hole_count", world_positions.size())
	#
	#for i in world_positions.size():
		#shader_material.set_shader_parameter("hole_positions[%d]" % i, world_positions[i])

func _add_body_atencao(body : Node2D) -> void:
	pass
	#print("dentro: ", body)
	#body.z_index += 10
	#objetos_atras.append(body)

func _rem_body_atencao(body : Node2D) -> void:
	pass
	#body.z_index -= 10
	#objetos_atras.erase(body)
