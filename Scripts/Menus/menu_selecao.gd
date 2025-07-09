extends Menu

@onready var label_status_P1 := $ControlesConectados/LabelStatusP1
@onready var label_status_P2 := $ControlesConectados/LabelStatusP2

@onready var container_leveis := $ScrollContainerLeveis/HBoxContainer
@onready var scroll_container := $ScrollContainerLeveis

var leveis_itens = []
var leveis_itens_por_level_id : Dictionary[LevelManager.Level_id, LevelItem] = {}

func _ready() -> void:
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	update_conectados() # atualiza no inicio
	# cria os displays de cada level
	_criar_level_itens()

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

# --- Leveis ---
func _criar_level_itens() -> void:
	var item_ref = preload("res://Cenas/Menus/SubItems/level_item.tscn")
	for level_id in LevelManager.LEVEIS_SELECAO_ORDEM:
		var item = item_ref.instantiate()
		leveis_itens.append(item)
		container_leveis.add_child(item)
		# add no dicionario
		leveis_itens_por_level_id[level_id] = item
		# link botao com inicio do level
		item.ajust(level_id)
	# pre seleciona o proximo level (ou o inicial se acabou de abrir)
	print('Globais.current_level_id ', Globais.current_level_id)
	print('leveis_itens ', leveis_itens)
	if leveis_itens_por_level_id.has(Globais.current_level_id):
		var item_focus = leveis_itens_por_level_id[Globais.current_level_id]
		item_focus.btn_grab_focus()
		await get_tree().process_frame
		scroll_container.ensure_control_visible(item_focus)
	else: # se nao tinha na lista de leveis jogaveis -> pega o primeiro level da lista
		leveis_itens[0].btn_grab_focus()

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
