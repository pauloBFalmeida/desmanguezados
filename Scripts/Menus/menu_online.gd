extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var text_nome: LineEdit = $VBox/TextNome

@onready var button_host: Button = $VBox/HBoxJog/ButtonHost
@onready var button_join: Button = $VBox/HBoxJog/ButtonJoin

@onready var text_ip: LineEdit = $VBox/GridContainer/TextIP
@onready var text_port: SpinBox = $VBox/GridContainer/SpinBoxPort

@onready var pop_up_conectando: Control = $PopUpConectando
@onready var rich_text_conectando: RichTextLabel = $PopUpConectando/RichTextConectando
@onready var v_box: VBoxContainer = $VBox

@onready var popup_error: Popup = $PopupError
@onready var label_popup_error: Label = $PopupError/LabelPopupError


var is_host : bool = true

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _ready() -> void:
	button_host.grab_focus()
	# ---
	pop_up_conectando.hide()
	# ---
	text_ip.placeholder_text = Networking.get_local_ipv4()
	update_button_server_visual()
	# ---
	Networking.display_error.connect(_display_error)

func _on_button_comecar_pressed() -> void:
	# -- visual --
	if is_host:
		rich_text_conectando.append_text("Cliente")
	else :
		rich_text_conectando.append_text("Host")
	pop_up_conectando.show()
	v_box.hide()
	# -- nome jogador --
	NetworkingGame.jogador_nome = _get_nome_jogador()
	# -- conexao --
	Networking.ip_addr = text_ip.text
	Networking.port = int(text_port.value)
	if is_host:
		Networking.create_server()
	else:
		Networking.create_client()

func _display_error(txt : String) -> void:
	label_popup_error.text = txt
	popup_error.popup_centered_clamped()

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

const nomes_possiveis : Array[String] = [
	"Miguel",
	"Arthur",
	"Gael",
	"Heitor",
	"Helena",
	"Alice",
	"Rafa",
	"Laura",
	"Davi",
	"Sophia",
	"Bernardo",
	"Valentina",
	"Gabriel",
	"Isadora",
	"Vulpe",
	"Manuela",
	"Paulo",
	"Julia",
	"Lucas",
    "Cecilia"
]
func _get_nome_jogador() -> String:
	if text_nome.text.length() < 1:
		return nomes_possiveis.pick_random()
	return text_nome.text
