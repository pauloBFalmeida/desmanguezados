extends Node
class_name OnlineHelperSelecaoLevel

@export var menu_selecao : MenuSelecao

static func criar(_menu_selecao : MenuSelecao) -> OnlineHelperSelecaoLevel:
	# cria o OnlineHelperSelecaoLevel
	var node_ref = load("uid://bexmg8hvs1d3b")
	var new_node = node_ref.instantiate()
	# ajusta o menu selecao
	var helperSelecao : OnlineHelperSelecaoLevel = new_node
	helperSelecao.menu_selecao = _menu_selecao
	return helperSelecao

func _ready() -> void:
	print(menu_selecao)
