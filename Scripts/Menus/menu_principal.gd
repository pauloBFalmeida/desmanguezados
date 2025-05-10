extends Control

func _ready() -> void:
	$GridContainer/ButtonJogar.grab_focus()

func _on_button_jogar_pressed() -> void:
	pass # Replace with function body.


func _on_button_config_pressed() -> void:
	pass

func _on_button_sair_pressed() -> void:
	get_tree().quit()
