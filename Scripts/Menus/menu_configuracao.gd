extends Menu

@onready var btn_voltar := $ButtonVoltar

# -- GamePlay --
@onready var toggle_aim_all_time := $VBoxContainer/AimAllTime
@onready var toggle_tracking_color := $VBoxContainer/TrackingColor
# -- Audio --
@onready var slider_musica_menu := $VBoxContainer/GridContainer/HSliderMusicaMenu
@onready var slider_musica_partida := $VBoxContainer/GridContainer/HSliderMusicaPartida
@onready var slider_efeitos_partida := $VBoxContainer/GridContainer/HSliderEffects

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
