extends Menu
class_name MenuSelecao

@onready var container_leveis := $ScrollContainerLeveis/HBoxContainer
@onready var scroll_container := $ScrollContainerLeveis
@onready var button_voltar: Button = $ButtonVoltar

var leveis_itens = []
var leveis_itens_por_level_id : Dictionary[LevelManager.Level_id, LevelItem] = {}

func _ready() -> void:
	# cria os displays de cada level
	_criar_level_itens()
	# -- Online --
	if NetworkingGame.is_game_online: 
		add_child(OnlineHelperSelecaoLevel.criar(self))
		## Desliga o input de voltar pro menu principal (ui_back -> Esc ou PS_bolinha) 
		set_process_input(false)

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	if NetworkingGame.is_game_online:
		SceneManager.full_goto_menu()
		return
	voltar_menu_principal()

# --- Leveis ---
func _criar_level_itens() -> void:
	var item_ref = preload("res://Cenas/Menus/SubItems/level_item.tscn")
	for level_id in LevelManager.LEVEIS_SELECAO_ORDEM:
		var item : LevelItem = item_ref.instantiate()
		leveis_itens.append(item)
		container_leveis.add_child(item)
		# add no dicionario
		leveis_itens_por_level_id[level_id] = item
		# link botao com inicio do level
		item.ajust(level_id)
		# conecta o apertar com chamar iniciar o level
		item.pressed.connect(SceneManager.goto_level.bind(level_id))
	# pre seleciona o proximo level (ou o inicial se acabou de abrir)
	if leveis_itens_por_level_id.has(Globais.current_level_id):
		var item_focus = leveis_itens_por_level_id[Globais.current_level_id]
		item_focus.btn_grab_focus()
		await get_tree().process_frame
		scroll_container.ensure_control_visible(item_focus)
	else: # se nao tinha na lista de leveis jogaveis -> pega o primeiro level da lista
		leveis_itens[0].btn_grab_focus()
