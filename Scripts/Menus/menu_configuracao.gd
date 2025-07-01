extends Menu

@onready var btn_voltar := $ButtonVoltar

# -- GamePlay --
@onready var toggle_aim_all_time := $VBoxContainer/AimAllTime
@onready var toggle_tracking_color := $VBoxContainer/TrackingColor
# -- Audio --
@onready var slider_musica_menu := $VBoxContainer/GridContainer/HSliderMusicaMenu
@onready var slider_musica_partida := $VBoxContainer/GridContainer/HSliderMusicaPartida
@onready var slider_efeitos_partida := $VBoxContainer/GridContainer/HSliderEffects
# -- Audio --
@onready var toggle_deletar_partida := $VBoxContainer/GridContainerSave/ButtonDeletarPartida
@onready var toggle_deletar_todo := $VBoxContainer/GridContainerSave/ButtonDeletarTodo
@onready var label_deletar_partida_certeza := $VBoxContainer/GridContainerSave/ButtonDeletarPartidaCerteza
@onready var label_deletar_todo_certeza := $VBoxContainer/GridContainerSave/ButtonDeletarTodoCerteza
@onready var button_deletar_partida_certeza := $VBoxContainer/GridContainerSave/LabelPartidaCerteza
@onready var button_deletar_todo_certeza := $VBoxContainer/GridContainerSave/LabelTodoCerteza

@onready var itens_partida := [button_deletar_partida_certeza, label_deletar_partida_certeza]
@onready var itens_todo := [label_deletar_todo_certeza, button_deletar_todo_certeza]

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()
	SaveManager.save_game()

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	_carregar_dados()

# --------- Carregar os dados do disco ---------
func _carregar_dados() -> void:
	# -- GamePlay --
	toggle_aim_all_time.set_pressed_no_signal(Globais.possivel_aim_all_time)
	
	var desativar_transparente : bool = not Globais.indicador_direcao_transparente_sem_target
	toggle_tracking_color.set_pressed_no_signal(desativar_transparente)
	# -- Audio --
	slider_musica_menu.set_value_no_signal(Globais.volume_musica_menu)
	slider_musica_partida.set_value_no_signal(Globais.volume_musica_partida)
	slider_efeitos_partida.set_value_no_signal(Globais.volume_efeitos_partida)
	# -- Deletar Save --
	_on_button_deletar_partida_toggled(false)
	_on_button_deletar_todo_toggled(false)

# --------- GamePlay ---------
func _on_aim_all_time_toggled(toggled_on: bool) -> void:
	Globais.possivel_aim_all_time = toggled_on
	print("all time set to ", Globais.possivel_aim_all_time)

func _on_tracking_color_toggled(toggled_on: bool) -> void:
	var ficar_transparente : bool = not toggled_on
	Globais.indicador_direcao_transparente_sem_target = ficar_transparente
	print("transparente set to ", Globais.indicador_direcao_transparente_sem_target)

# --------- Audio ---------
func _on_h_slider_musica_menu_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_musica_menu = slider_musica_menu.value
	# ajusta na musica atual do menu
	get_parent().update_volume_musica_menu()

func _on_h_slider_musica_partida_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_musica_partida = slider_musica_partida.value

func _on_h_slider_effects_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_efeitos_partida = slider_efeitos_partida.value

# --------- Deletar Save ---------
func _on_button_deletar_partida_toggled(toggled_on: bool) -> void:
	lidar_toggle(toggled_on, toggle_deletar_partida, itens_partida)

func _on_button_deletar_todo_toggled(toggled_on: bool) -> void:
	lidar_toggle(toggled_on, toggle_deletar_todo, itens_todo)

func _on_button_deletar_certeza_pressed() -> void:
	# deletar o save
	SaveManager.reset_save()
	# mostrar q deletou
	label_deletar_partida_certeza.text = "Dados deletados!"
	button_deletar_partida_certeza.hide()
	toggle_deletar_partida.hide()
	# volta o cursor para o btn de voltar
	btn_voltar.grab_focus()

func _on_button_deletar_todo_certeza_pressed() -> void:
	# deletar o save
	SaveManager.reset_save()
	# mostrar q deletou
	label_deletar_todo_certeza.text = "Dados deletados!"
	button_deletar_todo_certeza.hide()
	toggle_deletar_todo.hide()
	# volta o cursor para o btn de voltar
	btn_voltar.grab_focus()


func lidar_toggle(toggled_on: bool, toggle_btn : Button, itens : Array) -> void:
	# clicou para deletar
	if toggled_on:
		toggle_btn.text = "Não, manter dados"
		for item in itens:
			item.show()
	else:
		toggle_btn.text = "Deletar"
		for item in itens:
			item.hide()
