extends Control

func _ready() -> void:
	$GridContainer/ButtonJogar.grab_focus()

func _on_button_jogar_pressed() -> void:
	SceneManager.change_scene("res://Cenas/Menus/node_2d.tscn")

func _on_button_config_pressed() -> void:
	pass

func _on_button_sair_pressed() -> void:
	get_tree().quit()
