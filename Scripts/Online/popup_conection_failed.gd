class_name PopupConectionFailed
extends PopupPanel

@export var label_texto: Label
@onready var button: Button = $Margin/VBox/Button

func set_texto(txt: String) -> void:
	label_texto.text = txt

func _ready() -> void:
	await get_tree().process_frame
	# desabilita o botao
	button.disabled = true
	button.grab_focus()
	
	# espera um pouco antes de habilitar o botao
	await get_tree().create_timer(1.0, true).timeout
	button.disabled = false

func _on_button_pressed() -> void:
	# volta para o menu
	SceneManager.full_goto_menu()
	# espera a cena mudar
	await get_tree().physics_frame
	# deleta o pop up
	queue_free()
