extends Node

const MENU_PRINCIPAL_PATH := "res://Cenas/Menus/menuPrincipal.tscn"
const MENU_SELECAO_PATH := "res://Cenas/Menus/menuSelecao.tscn"

#const level_paths := {
	#LevelData.Level_t.TUTORIAL: "res://Scenes/Levels/level_Tutorial.tscn",
#}

func goto_menu():
	change_scene(MENU_PRINCIPAL_PATH)

func goto_selecao():
	change_scene(MENU_SELECAO_PATH)

#func goto_level(level: LevelData.Level_t):
	#if level_paths.has(level):
		#change_scene(level_paths[level])

# ------  ---------
func change_scene(path: String):
	# Clean up current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	
	# Load new scene
	var new_scene = load(path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
