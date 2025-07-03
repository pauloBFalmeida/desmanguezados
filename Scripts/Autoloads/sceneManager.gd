extends Node

const MENUS_PATH := "res://Cenas/Menus/mainMenus.tscn"
const MENU_PRINCIPAL_PATH := "res://Cenas/Menus/menuPrincipal.tscn"
const MENU_SELECAO_PATH := "res://Cenas/Menus/menuSelecao.tscn"
const MENU_MENU_ZEN_PATH := "res://Cenas/Menus/menuZen.tscn"
const MENU_CONFIGURACAO_PATH := "res://Cenas/Menus/menuConfiguracao.tscn"
const MENU_CREDITOS_PATH := "res://Cenas/Menus/menuCreditos.tscn"

const LEVEIS_REF  : Dictionary[Globais.Level_id, String] = {
	Globais.Level_id.ZEN: "res://Cenas/Leveis/level_zen.tscn",
	Globais.Level_id.TUTORIAL: "res://Cenas/Leveis/level_0_tutorial.tscn",
	Globais.Level_id.LEVEL_1: "res://Cenas/Leveis/level_1.tscn",
	Globais.Level_id.LEVEL_2: "res://Cenas/Leveis/level_2.tscn",
	Globais.Level_id.LEVEL_3: "res://Cenas/Leveis/level_3.tscn",
	Globais.Level_id.LEVEL_4: "res://Cenas/Leveis/level_4pt2.tscn",
	Globais.Level_id.LEVEL_5: "res://Cenas/Leveis/level_5.tscn",
}

func goto_menu():
	change_scene(MENUS_PATH)

func goto_menu_principal():
	change_menu(MENU_PRINCIPAL_PATH)

func goto_selecao():
	change_menu(MENU_SELECAO_PATH)

func goto_menu_zen():
	change_menu(MENU_MENU_ZEN_PATH)

func goto_configuracoes():
	change_menu(MENU_CONFIGURACAO_PATH)

func goto_creditos():
	change_menu(MENU_CREDITOS_PATH)

func goto_level(level_id : Globais.Level_id):
	if LEVEIS_REF.has(level_id):
		Globais.current_level_id = level_id
		change_scene(LEVEIS_REF[level_id])

func restart_level() -> void:
	goto_level(Globais.current_level_id)

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

func change_menu(path: String):
	var main_menus = get_tree().root.get_node("MainMenus")
	# Clean up current scene
	for child in main_menus.get_children():
		child.queue_free()
	
	# Load new scene
	var scene_ref = load(path)
	var new_scene = scene_ref.instantiate()
	main_menus.add_child(new_scene)
