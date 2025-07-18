extends Control

@onready var label_status_P1 := $LabelStatusP1
@onready var label_status_P2 := $LabelStatusP2

func _ready() -> void:
	# controle conectado -> atualiza as informacoes de controles conectados
	InputManager.controle_added.connect(update_conectados)
	update_conectados() # atualiza no inicio

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
		label_status_P1.text = _get_controle_texto(Globais.controle_tipo_P1)
	else:
		label_status_P1.text = "WASD"
	# Player 2
	if is_controle_conectado[InputManager.PlayerId.P2]:
		label_status_P2.text = _get_controle_texto(Globais.controle_tipo_P2)
	else:
		label_status_P2.text = "Setas"

func _get_controle_texto(controle_tipo : InputManager.Controle_tipo) -> String:
	return ("Controle "
			+ InputManager.controle_tipo_string[controle_tipo]
			+ " Conectado")
