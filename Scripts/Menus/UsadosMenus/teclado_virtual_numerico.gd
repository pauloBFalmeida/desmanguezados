class_name TecladoVirtualNumerico
extends TecladoVirtual

@onready var grid_numeros: GridContainer = $HBoxContainer/GridNumeros
@onready var button_0: Button = $HBoxContainer/VBoxNumerosExtra/Button_0
@onready var button_p: Button = $HBoxContainer/VBoxNumerosExtra/Button_p

# -----------------------------------------------------------------------------
func _ready() -> void:
	# -- funcionamento dos digitos
	# grid numeros
	for i: int in grid_numeros.get_child_count():
		var btn: Button = grid_numeros.get_child(i)
		var char_n : String = str(i + 1)
		btn.pressed.connect(_apertar.bind(char_n))
	# extras
	button_0.pressed.connect(_apertar.bind("0"))
	button_p.pressed.connect(_apertar.bind("."))

# -----------------------------------------------------------------------------
func _on_button_aceitar_pressed() -> void:
	_fechar_apertado()

func _on_button_corrigir_pressed() -> void:
	_corrigir_apertado()

func _on_button_voltar_pressed() -> void:
	_fechar_apertado()
