extends Menu

@onready var btn_voltar := $ButtonVoltar
@onready var btn_next := $ButtonNext
@onready var btn_prev := $ButtonPrev

var curr_tela_id : int = 0

@export var lista_telas : Array[Control]

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	mostrar_tela()

func mostrar_tela() -> void:
	# mostra somente a tela atual
	for id in range(len(lista_telas)):
		if id == curr_tela_id:
			lista_telas[id].show()
		else:
			lista_telas[id].hide()
	# mostra btn next se tiver proxima
	print(curr_tela_id)
	if curr_tela_id < len(lista_telas) -1:
		btn_next.disabled = false
		btn_next.show()
	else:
		btn_next.disabled = true
		btn_next.hide()
		btn_prev.grab_focus()
	# mostra btn prev se tiver anterior
	if curr_tela_id > 0:
		btn_prev.disabled = false
		btn_prev.show()
	else:
		btn_prev.disabled = true
		btn_prev.hide()
		btn_next.grab_focus()

func _on_button_next_pressed() -> void:
	curr_tela_id += 1
	mostrar_tela()

func _on_button_prev_pressed() -> void:
	curr_tela_id -= 1
	mostrar_tela()
