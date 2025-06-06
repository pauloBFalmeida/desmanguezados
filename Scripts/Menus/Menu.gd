class_name Menu
extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		voltar_menu_principal()

func voltar_menu_principal() -> void:
	SceneManager.goto_menu()
