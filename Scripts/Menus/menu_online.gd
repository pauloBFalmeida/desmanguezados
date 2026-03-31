extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var button_host: Button = $VBox/HBoxJog/ButtonHost
@onready var button_join: Button = $VBox/HBoxJog/ButtonJoin

@onready var text_ip: LineEdit = $VBox/GridContainer/TextIP
@onready var text_port: SpinBox = $VBox/GridContainer/SpinBoxPort

var is_host : bool = true

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _ready() -> void:
	button_host.grab_focus()
	# ---
	text_ip.placeholder_text = _get_local_ipv4()
	update_button_server_visual()

func _on_button_comecar_pressed() -> void:
	pass # Replace with function body.


func _get_local_ipv4() -> String:
	for address in IP.get_local_addresses():
		# pega enderecos IP v4
		if (address.split('.').size() == 4):
			# IP interno, normalmente na forma 192.168.*.*
			if address.contains("192.168"):
				return address
	# IP para localhost, ambos jogos rodando no mesmo PC
	return "127.0.0.1"

# --- Botoes Host e Join ---
func update_button_server_visual() -> void:
	if is_host:
		button_host.set_pressed_no_signal(true)
		button_join.set_pressed_no_signal(false)
		text_ip.editable = false
	else:
		button_host.set_pressed_no_signal(false)
		button_join.set_pressed_no_signal(true)
		text_ip.editable = true

func _on_button_host_pressed() -> void:
	is_host = true
	update_button_server_visual()

func _on_button_join_pressed() -> void:
	is_host = false
	update_button_server_visual()
