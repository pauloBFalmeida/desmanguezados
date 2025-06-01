extends Node

const MENU_PRINCIPAL_PATH := "res://Cenas/Menus/menuPrincipal.tscn"
const MENU_SELECAO_PATH := "res://Cenas/Menus/menuSelecao.tscn"

const LEVEIS_REF : Array[String] = [
	"res://Cenas/Leveis/level_1.tscn"
]

#const level_paths := {
	#LevelData.Level_t.TUTORIAL: "res://Scenes/Levels/level_Tutorial.tscn",
#}

func goto_menu():
	change_scene(MENU_PRINCIPAL_PATH)

func goto_selecao():
	change_scene(MENU_SELECAO_PATH)

func goto_level(level_num: int):
	if level_num < len(LEVEIS_REF) and level_num >= 0:
		change_scene(LEVEIS_REF[level_num])

# ------  ---------
func change_scene(path: String):
	# Clean up current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	
	# Load new scene
	var scene_ref = load(path)
	var new_scene = scene_ref.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
