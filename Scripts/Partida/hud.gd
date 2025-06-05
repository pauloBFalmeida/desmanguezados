extends Control
class_name Hud

@onready var label_qtd_mudas := $LabelMudas
@onready var label_cronometro := $LabelTempo

@onready var game_over_menu := $GameOverMenu
@onready var game_over_sprite := $GameOverMenu/ImagemFim
@onready var game_over_btn_replay := $GameOverMenu/ButtonReplay

@onready var pause_menu := $PauseMenu
@onready var pause_menu_btn_jogo := $PauseMenu/VBoxContainer/ButtonJogo

@onready var start_menu := $StartMenu
@onready var start_label_count := $StartMenu/VBoxContainer/LabelStartCount
@export var start_count_num : int = 3
var is_comecando_contar : bool = false

@onready var temporizador := $Temporizador

enum Tipo_fim {DERROTA_TEMPO, VITORIA_SUJO, VITORIA_LIMPO}

@export var imagens_fim_jogo : Dictionary[Tipo_fim, CompressedTexture2D]

func _ready() -> void:
	# esconde as telas
	start_menu.hide()
	game_over_menu.hide()
	_despausar()

## atualiza a label que conta quantas mudas tem que ser plantadas
func update_mudas(qtd_mudas : int) -> void:
	label_qtd_mudas.text = "Quantidade de Árvores a serem plantadas: " + str(qtd_mudas)

## atualiza a label do cronometro
func update_tempo(texto : String) -> void:
	label_cronometro.text = texto


func _goto_menu() -> void:
	get_tree().paused = false
	SceneManager.goto_menu()
	
func _replay() -> void:
	get_tree().paused = false
	SceneManager.restart_level()

# ---- Menu Pause ----
func toggle_pausar() -> void:
	# nao pausar se estiver na contagem inicial
	if is_comecando_contar: return
	
	# nao esta pausado
	if not get_tree().paused:
		_pausar()
	else: # ja esta pausado
		_despausar()

func _pausar() -> void:
	get_tree().paused = true
	pause_menu.show()
	pause_menu_btn_jogo.grab_focus()
	
func _despausar() -> void:
	pause_menu.hide()
	get_tree().paused = false

func _on_button_jogo_pressed() -> void:
	_despausar()

func _on_button_restart_pressed() -> void:
	_replay()

func _on_button_menu_pressed() -> void:
	_goto_menu()

# ---- Menu Comeco ----
func comecar_contar() -> void:
	# -- pre contar --
	is_comecando_contar = true
	start_menu.show()
	get_tree().paused = true
	# -- contar --
	while (start_count_num > 0):
		start_label_count.text = str(start_count_num)
		await get_tree().create_timer(1.0, true).timeout
		start_count_num -= 1
	# -- pos contar --
	start_menu.hide()
	get_tree().paused = false
	is_comecando_contar = false
	# comeca o temporizador
	temporizador.comecar()

# ---- Menu Game Over ----
func show_tela_fim(tipo : Tipo_fim) -> void:
	# mostra o menu de fim de jogo
	game_over_menu.show()
	game_over_btn_replay.grab_focus()
	
	# ajusta a imagem dependendo do tipo de fim de jogo
	game_over_sprite.texture = imagens_fim_jogo[tipo]
	
	# salva o tamanho da sprite e diminui ela
	var scale_final : Vector2 = game_over_sprite.scale 
	game_over_sprite.scale = game_over_sprite.scale * 0.01
	
	# animacao de aumentar a sprite
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(
		game_over_sprite, "scale",
		scale_final,
		1.5 # seg
	).from_current()
	
	# TODO: fazer algo especial para cada tela ?
	#match tipo:
		#Tipo_fim.DERROTA_TEMPO:
			#pass
		#Tipo_fim.VITORIA_SUJO:
			#pass
		#Tipo_fim.VITORIA_LIMPO:
			#pass

func _on_button_replay_pressed() -> void:
	_replay()

func _on_button_menu_gameover_pressed() -> void:
	_goto_menu()
