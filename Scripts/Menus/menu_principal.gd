extends Control

func _ready() -> void:
	$GridContainer/ButtonJogar.grab_focus()

func _on_button_jogar_pressed() -> void:
	SceneManager.goto_selecao()

func _on_button_config_pressed() -> void:
	SceneManager.goto_configuracoes()

func _on_button_sair_pressed() -> void:
	get_tree().quit()
