class_name TecladoVirtualNomes
extends TecladoVirtual

@onready var button_nome_ref: Button = $Button_nome_ref
@onready var h_box_nomes: HBoxContainer = $VBox/ScrollNomes/Margin/HBoxNomes

@onready var button_voltar: Button = $VBox/Button_Voltar

# -----------------------------------------------------------------------------
func _ready() -> void:
	var primeiro := true
	var ultimo : Button
	
	for nome: String in Globais.nomes_possiveis:
		var button: Button = button_nome_ref.duplicate()
		button.text = nome
		button.pressed.connect(_apertar_nome.bind(nome))
		#
		h_box_nomes.add_child(button)
		button.show()
		# 
		button.focus_neighbor_bottom = button_voltar.get_path()
		button.focus_neighbor_top = button.get_path()
		#
		ultimo = button
		#
		if (primeiro):
			primeiro = false
			button_voltar.focus_neighbor_top = button.get_path()
			button.focus_neighbor_left = button.get_path()
	
	# 
	ultimo.focus_neighbor_right = ultimo.get_path()

# -----------------------------------------------------------------------------
func _apertar_nome(nome: String) -> void:
	clear_pressed.emit()
	char_pressed.emit(nome)
	fechar_pressed.emit()

func _on_button_voltar_pressed() -> void:
	_fechar_apertado()
