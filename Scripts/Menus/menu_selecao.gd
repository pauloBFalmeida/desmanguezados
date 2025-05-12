extends Control

@onready var label_status_P1 := $ControlesConectados/LabelStatusP1
@onready var label_status_P2 := $ControlesConectados/LabelStatusP2

@onready var container_leveis := $ScrollContainerLeveis/HBoxContainer

const LEVEIS_REF := [
	"res://Cenas/Menus/node_2d.tscn"
]

var leveis_itens = []

func _ready() -> void:
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	update_conectados() # atualiza no inicio
	# cria os displays de cada level
	_criar_level_itens()

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	SceneManager.goto_menu()

# --- Leveis ---
func _criar_level_itens() -> void:
	var item_ref = preload("res://Cenas/Menus/SubItems/level_item.tscn")
	for level_ref in LEVEIS_REF:
		var item = item_ref.instantiate()
		leveis_itens.append(item)
		container_leveis.add_child(item)
		# link botao com inicio do level
		var btn : Button = item.get_node("ButtonStart")
		btn.pressed.connect(func(): SceneManager.change_scene(level_ref) )
		# texto
		var level_num = leveis_itens.size()
		btn.text = "Level " + str(level_num)
	leveis_itens[0].get_node("ButtonStart").grab_focus()

func _on_button_pressed() -> void:
	SceneManager.change_scene("res://Cenas/Menus/node_2d.tscn")

# --- Controles Conectados ---
func update_conectados():
	# dict de quais controles foram conectados
	var is_controle_conectado := {
		InputManager.PlayerId.P1: false,
		InputManager.PlayerId.P2: false
	}
	# Encontra os players com os controles conectados
	for device_id in InputManager.controles_conectados:
		var player_id = InputManager.controles_conectados[device_id]
		is_controle_conectado[player_id] = true
	
	# -- atualiza as labels --
	# Player 1
	if is_controle_conectado[InputManager.PlayerId.P1]:
		label_status_P1.text = "Controle Conectado"
	else:
		label_status_P1.text = "WASD"
	# Player 2
	if is_controle_conectado[InputManager.PlayerId.P2]:
		label_status_P2.text = "Controle Conectado"
	else:
		label_status_P2.text = "Setas"
