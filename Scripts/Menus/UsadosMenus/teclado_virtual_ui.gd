class_name TecladoVirtualUI
extends Control

@export var teclados_tipos_ref: Dictionary[TecladoVirtual.Tipo, PackedScene]

var teclados_tipos: Dictionary[TecladoVirtual.Tipo, TecladoVirtual]
@onready var margin_teclado: MarginContainer = $Margin

var teclado_virtual: TecladoVirtual

var input_node: Control

func _ready() -> void:
	hide()
	# criar os teclados
	_criar_teclados()

func mostrar(_input_node: Control, 
				tipo: TecladoVirtual.Tipo = TecladoVirtual.Tipo.NUMERICO) -> void:
	show()
	set_input(_input_node)
	#
	_mostrar_teclado_tipo(tipo)
	await get_tree().process_frame
	teclado_virtual.foco_inicial.grab_focus()

func esconder() -> void:
	hide()
	await get_tree().process_frame
	input_node.find_next_valid_focus().grab_focus()


func _mostrar_teclado_tipo(tipo: TecladoVirtual.Tipo) -> void:
	teclado_virtual.hide()
	teclado_virtual = teclados_tipos[tipo]
	teclado_virtual.show()

func _criar_teclados() -> void:
	for tipo: TecladoVirtual.Tipo in teclados_tipos_ref.keys():
		var teclado: TecladoVirtual = teclados_tipos_ref[tipo].instantiate()
		margin_teclado.add_child(teclado)
		teclado.hide()
		# sinais
		teclado.fechar_pressed.connect(_fechar_apertado)
		teclado.corrigir_pressed.connect(_corrigir_apertado)
		teclado.char_pressed.connect(_char_apertado)
		# adiciona
		teclados_tipos[tipo] = teclado
	teclado_virtual = teclados_tipos[0]

# -----------------------------------------------------------------------------
func set_input(_input_node: Control) -> void:
	input_node = _input_node

func add_char_input(_char: String) -> void:
	if input_node is LineEdit:
		#input_node.text += _char
		input_node.insert_text_at_caret(_char)
	elif input_node is SpinBox:
		input_node.value = input_node.value * 10 + int(_char)

func rem_char_input() -> void:
	if input_node is LineEdit:
		if input_node.text.length() < 1: return
		input_node.text = _get_str_menos_1_char(input_node.text)
	elif input_node is SpinBox:
		if input_node.value < 1: return
		var valor: int = int(input_node.value)
		valor = (valor - valor%10) / 10
		input_node.value = float(valor)

func _get_str_menos_1_char(_text: String) -> String:
	if _text.length() < 1: return ""
	return _text.erase(_text.length()-1, 1)

# -----------------------------------------------------------------------------
func _fechar_apertado() -> void:
	esconder()

func _corrigir_apertado() -> void:
	rem_char_input()

func _char_apertado(_char: String) -> void:
	add_char_input(_char)
