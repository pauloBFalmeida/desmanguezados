extends Menu

@onready var button_foco := $GridContainer/Button1Jog

func _ready() -> void:
	button_foco.grab_focus()

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

# --- Botoes quantidade de jogadores ---
func _on_button_1_jog_pressed() -> void:
	Configuracoes.modo_zen_ter_1_jogador = true
	SceneManager.goto_level(SceneManager.Level_id.ZEN)

func _on_button_2_jog_pressed() -> void:
	Configuracoes.modo_zen_ter_1_jogador = false
	SceneManager.goto_level(SceneManager.Level_id.ZEN)
