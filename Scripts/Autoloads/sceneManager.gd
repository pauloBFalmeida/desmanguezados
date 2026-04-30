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

func full_goto_menu() -> void:
	change_scene(MENUS_PATH)

func full_goto_selecao() -> void:
	change_scene(MENU_SELECAO_PATH)


func goto_menu_principal() -> void:
	change_menu(MENU_PRINCIPAL_PATH)

func goto_selecao() -> void:
	change_menu(MENU_SELECAO_PATH)

func goto_online() -> void:
	change_menu(MENU_ONLINE_PATH)

func goto_menu_zen() -> void:
	change_menu(MENU_MENU_ZEN_PATH)

func goto_configuracoes() -> void:
	change_menu(MENU_CONFIGURACAO_PATH)

func goto_creditos() -> void:
	change_menu(MENU_CREDITOS_PATH)

func goto_stats() -> void:
	change_menu(MENU_ESTATISTICAS_PATH)

func goto_info() -> void:
	change_menu(MENU_INFORMACOES_PATH)

func goto_level(level_id : LevelManager.Level_id) -> void:
	if LevelManager.LEVEIS_REF.has(level_id):
		Globais.current_level_id = level_id
		change_scene(LevelManager.LEVEIS_REF[level_id])

func restart_level() -> void:
	goto_level(Globais.current_level_id)

# ------  ---------
func change_scene(path: String) -> void:
	# Clean up current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()
	
	# Load new scene
	var new_scene = _load_scene(path)
	get_tree().root.add_child(new_scene, true)
	get_tree().current_scene = new_scene

func change_menu(path: String) -> void:
	var main_menus = get_tree().current_scene
	# Clean up current scene
	for child in main_menus.get_children():
		child.queue_free()
	
	# Load new scene
	main_menus.add_child(_load_scene(path))

func _load_scene(path: String) -> Node:
	var scene_ref = load(path)
	var new_scene = scene_ref.instantiate()
	return new_scene
