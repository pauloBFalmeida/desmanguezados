extends Control

func _ready() -> void:
	$GridContainer/ButtonJogar.grab_focus()

func _on_button_jogar_pressed() -> void:
	SceneManager.goto_selecao()

func _on_button_zen_pressed() -> void:
	pass # Replace with function body.

func _on_button_config_pressed() -> void:
	SceneManager.goto_configuracoes()

func _on_button_creditos_pressed() -> void:
	SceneManager.goto_menu_zen()

func _on_button_sair_pressed() -> void:
	get_tree().quit()
