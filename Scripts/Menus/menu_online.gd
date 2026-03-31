extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var button_host: Button = $VBox/HBoxJog/ButtonHost
@onready var button_join: Button = $VBox/HBoxJog/ButtonJoin

@onready var text_ip: LineEdit = $VBox/GridContainer/TextIP
@onready var spin_box_port: SpinBox = $VBox/GridContainer/SpinBoxPort

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _ready() -> void:
	button_host.grab_focus()
	# ---

func _on_button_comecar_pressed() -> void:
	pass # Replace with function body.


# --- Botoes quantidade de jogadores ---
func update_button_server_visual() -> void:
	if host:
		button_host.set_pressed_no_signal(true)
		button_join.set_pressed_no_signal(false)
	else:
		button_host.set_pressed_no_signal(false)
		button_join.set_pressed_no_signal(true)
	

var host := true

func _on_button_host_pressed() -> void:
	host = true
	update_button_server_visual()

func _on_button_join_pressed() -> void:
	host = false
	update_button_server_visual()
