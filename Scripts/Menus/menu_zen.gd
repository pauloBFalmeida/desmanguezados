extends Menu

@onready var button_foco := $GridContainer/Button1Jog
@onready var text_seed := $TextEditSeed

func _ready() -> void:
	button_foco.grab_focus()
	# cria uma seed aleatoria
	Globais.modo_zen_mapa_seed = randi_range(0, 99999)
	text_seed.text = str(Globais.modo_zen_mapa_seed)

func comecar_partida() -> void:
	SceneManager.goto_level(Globais.Level_id.ZEN)
	Globais.modo_zen_mapa_seed = int(text_seed.text)

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

# --- Botoes quantidade de jogadores ---
func _on_button_1_jog_pressed() -> void:
	Globais.modo_zen_ter_1_jogador = true
	comecar_partida()

func _on_button_2_jog_pressed() -> void:
	Globais.modo_zen_ter_1_jogador = false
	comecar_partida()
