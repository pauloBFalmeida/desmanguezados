extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var toggle_aim_all_time := $VBoxContainer/AimAllTime
@onready var toggle_tracking_color := $VBoxContainer/TrackingColor

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	toggle_aim_all_time.set_pressed_no_signal(Configuracoes.possivel_aim_all_time)
	toggle_tracking_color.set_pressed_no_signal(Configuracoes.indicador_direcao_transparente_sem_target)

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _on_aim_all_time_toggled(toggled_on: bool) -> void:
	Configuracoes.possivel_aim_all_time = toggled_on
	print("all time set to ", Configuracoes.possivel_aim_all_time)

func _on_tracking_color_toggled(toggled_on: bool) -> void:
	Configuracoes.indicador_direcao_transparente_sem_target = toggled_on
	print("transparente set to ", Configuracoes.indicador_direcao_transparente_sem_target)

func _on_button_pressed() -> void:
	if $VBoxContainer/TextEditUsarP1.text.size() > 0:
		Configuracoes.string_pegar_controle_P1 = $VBoxContainer/TextEditUsarP1.text
	if $VBoxContainer/TextEditUsarP2.text.size() > 0:
		Configuracoes.string_pegar_controle_P2 = $VBoxContainer/TextEditUsarP2.text
	if $VBoxContainer/TextEditDropP1.text.size() > 0:
		Configuracoes.string_dropar_controle_P1 = $VBoxContainer/TextEditDropP1.text
	if $VBoxContainer/TextEditDropP2.text.size() > 0:
		Configuracoes.string_dropar_controle_P2 = $VBoxContainer/TextEditDropP2.text
