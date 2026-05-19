class_name TecladoVirtual
extends Control

signal fechar_pressed(prev_foco: Control)
signal botao_pressed(char: String)

@export var foco: Control

@onready var grid_numeros: GridContainer = $HBoxContainer/GridNumeros
@onready var button_0: Button = $HBoxContainer/VBoxNumerosExtra/Button_0
@onready var button_p: Button = $HBoxContainer/VBoxNumerosExtra/Button_p

var prev_foco: Control 

func _ready() -> void:
	hide()
	# -- sinais
	# grid numeros
	for i: int in grid_numeros.get_child_count():
		var btn: Button = grid_numeros.get_child(i)
		var char_n : String = str(i + 1)
		btn.pressed.connect(_apertar.bind(char_n))
	# extras
	button_0.pressed.connect(_apertar.bind("0"))
	button_p.pressed.connect(_apertar.bind("."))

# -----------------------------------------------------------------------------
func abrir(curr_foco: Control) -> void:
	show()
	prev_foco = curr_foco
	foco.grab_focus()

func fechar() -> void:
	hide()

# -----------------------------------------------------------------------------
func _fechar_apertado() -> void:
	fechar()
	fechar_pressed.emit(prev_foco)

func _apertar(_char: String) -> void:
	botao_pressed.emit(_char)

# -----------------------------------------------------------------------------
func _on_button_aceitar_pressed() -> void:
	_fechar_apertado()

func _on_button_corrigir_pressed() -> void:
	pass # Replace with function body.
	
func _on_button_voltar_pressed() -> void:
	_fechar_apertado()
