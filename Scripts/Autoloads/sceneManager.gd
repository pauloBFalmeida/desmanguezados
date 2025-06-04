extends Node

const MENU_PRINCIPAL_PATH := "res://Cenas/Menus/menuPrincipal.tscn"
const MENU_SELECAO_PATH := "res://Cenas/Menus/menuSelecao.tscn"

enum Level_id {TUTORIAL, LEVEL_1, LEVEL_2}

const LEVEIS_REF  : Dictionary[Level_id, String] = {
	Level_id.TUTORIAL: "res://Cenas/Leveis/level_0_tutorial.tscn",
	Level_id.LEVEL_1: "res://Cenas/Leveis/level_1.tscn",
}

const LEVEIS_NOME : Dictionary[Level_id, String] = {
	Level_id.TUTORIAL: "Tutorial",
	Level_id.LEVEL_1: "Level 1",
}

const LEVEIS_IMAGE : Dictionary[Level_id, CompressedTexture2D] = {
	#Level_id.TUTORIAL: preload()
}

var current_level_id : Level_id
#const level_paths := {
	#LevelData.Level_t.TUTORIAL: "res://Scenes/Levels/level_Tutorial.tscn",
#}

func goto_menu():
	change_scene(MENU_PRINCIPAL_PATH)

func goto_selecao():
	change_scene(MENU_SELECAO_PATH)

func goto_level(level_id : Level_id):
	if LEVEIS_REF.has(level_id):
		current_level_id = level_id
		change_scene(LEVEIS_REF[level_id])

func restart_level() -> void:
	goto_level(current_level_id)

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
