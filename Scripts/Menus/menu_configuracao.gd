extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var toggle_joystick_override := $VBoxContainer/JoystickOverride
@onready var toggle_tracking_color := $VBoxContainer/TrackingColor

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	toggle_joystick_override.set_pressed_no_signal(Configuracoes.possivel_joystick_override)
	toggle_tracking_color.set_pressed_no_signal(Configuracoes.indicador_direcao_transparente_sem_target)

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _on_joystick_override_toggled(toggled_on: bool) -> void:
	Configuracoes.possivel_joystick_override = toggled_on


func _on_tracking_color_toggled(toggled_on: bool) -> void:
	Configuracoes.indicador_direcao_transparente_sem_target = toggled_on

func _on_button_pressed() -> void:
	if $VBoxContainer/TextEditUsarP1.text.size() > 0:
		Configuracoes.string_pegar_controle_P1 = $VBoxContainer/TextEditUsarP1.text
	if $VBoxContainer/TextEditUsarP2.text.size() > 0:
		Configuracoes.string_pegar_controle_P2 = $VBoxContainer/TextEditUsarP2.text
	if $VBoxContainer/TextEditDropP1.text.size() > 0:
		Configuracoes.string_dropar_controle_P1 = $VBoxContainer/TextEditDropP1.text
	if $VBoxContainer/TextEditDropP2.text.size() > 0:
		Configuracoes.string_dropar_controle_P2 = $VBoxContainer/TextEditDropP2.text
