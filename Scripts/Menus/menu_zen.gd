extends Menu

@onready var button_foco := $ButtonComecar
@onready var button_jog1 := $GridContainer/HBoxJog/Button1Jog
@onready var button_jog2 := $GridContainer/HBoxJog/Button2Jog

@onready var valor_map_size := $GridContainer/SpinBoxMapSize
@onready var valor_lixo := $GridContainer/SpinBoxLixo
@onready var valor_pinos := $GridContainer/SpinBoxPinos
@onready var valor_mangue := $GridContainer/SpinBoxMangue
@onready var valor_seed := $GridContainer/SpinBoxSeed

func _ready() -> void:
	button_foco.grab_focus()
	# cria uma seed aleatoria
	Globais.modo_zen_mapa_seed = randi_range(0, 99999)
	# ajusta os mostradores
	valor_seed.set_value_no_signal(Globais.modo_zen_mapa_seed)
	valor_map_size.set_value_no_signal(Globais.modo_zen_mapa_size)
	valor_pinos.set_value_no_signal(  Globais.modo_zen_porcent_pinos  * 10)
	valor_mangue.set_value_no_signal( Globais.modo_zen_porcent_mangue * 10)
	valor_lixo.set_value_no_signal(   Globais.modo_zen_porcent_lixo   * 10)
	#
	update_button_jogadores_visual()

func comecar_partida() -> void:
	# ajustar as globais
	Globais.modo_zen_mapa_seed = valor_seed.value
	Globais.modo_zen_mapa_size = valor_map_size.value
	Globais.modo_zen_porcent_pinos  = valor_pinos.value  / 10
	Globais.modo_zen_porcent_mangue = valor_mangue.value / 10
	Globais.modo_zen_porcent_lixo   = valor_lixo.value   / 10
	# comecar a partida
	SceneManager.goto_level(LevelManager.Level_id.ZEN)

func _on_button_comecar_pressed() -> void:
	comecar_partida()

# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

# --- Botoes quantidade de jogadores ---
func _on_button_1_jog_pressed() -> void:
	Globais.modo_zen_ter_1_jogador = true
	update_button_jogadores_visual()

func _on_button_2_jog_pressed() -> void:
	Globais.modo_zen_ter_1_jogador = false
	update_button_jogadores_visual()

func update_button_jogadores_visual() -> void:
	if Globais.modo_zen_ter_1_jogador:
		button_jog1.set_pressed_no_signal(true)
		button_jog2.set_pressed_no_signal(false)
	else:
		button_jog1.set_pressed_no_signal(false)
		button_jog2.set_pressed_no_signal(true)
	
