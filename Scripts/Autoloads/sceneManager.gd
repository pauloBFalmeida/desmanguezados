extends Node

const MENUS_PATH 				:= "uid://4k8drpikovn2"
const MENU_PRINCIPAL_PATH 		:= "uid://e0hvhpdu6hbn"
const MENU_SELECAO_PATH 		:= "uid://d1fhoosfw8cye"
const MENU_ONLINE_PATH 			:= "uid://cbwykhriort25"
const MENU_MENU_ZEN_PATH 		:= "uid://c5wshuf5fpmi2"
const MENU_CONFIGURACAO_PATH	:= "uid://dl22uju6ygrp0"
const MENU_CREDITOS_PATH 		:= "uid://65vehrxtpinv"
const MENU_ESTATISTICAS_PATH	:= "uid://nbn4suesoxxx"
const MENU_INFORMACOES_PATH 	:= "uid://icyktkxgwl6u"

func goto_menu():
	change_scene(MENUS_PATH)

func goto_menu_principal():
	change_menu(MENU_PRINCIPAL_PATH)

func goto_selecao():
	change_menu(MENU_SELECAO_PATH)

func goto_online():
	change_menu(MENU_ONLINE_PATH)

func goto_menu_zen():
	change_menu(MENU_MENU_ZEN_PATH)

func goto_configuracoes():
	change_menu(MENU_CONFIGURACAO_PATH)

func goto_creditos():
	change_menu(MENU_CREDITOS_PATH)

func goto_stats():
	change_menu(MENU_ESTATISTICAS_PATH)

func goto_info():
	change_menu(MENU_INFORMACOES_PATH)

func goto_level(level_id : LevelManager.Level_id):
	if LevelManager.LEVEIS_REF.has(level_id):
		Globais.current_level_id = level_id
		change_scene(LevelManager.LEVEIS_REF[level_id])

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
