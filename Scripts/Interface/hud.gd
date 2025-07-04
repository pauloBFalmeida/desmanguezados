extends Control
class_name Hud

signal partida_comecando

# -- hud in game --
@onready var label_cronometro := $LabelTempo
@onready var barra_progresso := $BarraProgresso

# -- fim de jogo --
@onready var game_over_menu := $GameOverMenu
@onready var game_over_sprite := $GameOverMenu/ImagemFim
@onready var game_over_btns := $GameOverMenu/ControlBtns
@onready var game_over_btn_replay := $GameOverMenu/ControlBtns/ButtonReplay

# -- pause --
@onready var pause_menu := $PauseMenu
@onready var pause_menu_btn_jogo := $PauseMenu/VBoxContainer/ButtonJogo

# -- contagem do comeco de partida --
@onready var start_menu := $StartMenu
@onready var start_label_count := $StartMenu/VBoxContainer/LabelStartCount
@export var start_count_num : int = 3
var is_comecando_contar : bool = false

@onready var temporizador := $Temporizador

# -- musica de fundo --
@export var musica_level : AudioStream
@onready var audio_player_musica := $AudioStreamPlayer

enum Tipo_fim {DERROTA_TEMPO, VITORIA_SUJO, VITORIA_LIMPO}

@export var imagens_fim_jogo : Dictionary[Tipo_fim, CompressedTexture2D]

var despausado_recente : bool = false

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_back") or event.is_action_pressed("pause")) and get_tree().paused:
		despausar()

func _ready() -> void:
	_despausar()
	# ajusta o audio
	audio_player_musica.stream = musica_level
	audio_player_musica.stop()
	audio_player_musica.process_mode = Node.PROCESS_MODE_PAUSABLE
	audio_player_musica.volume_db = Globais.volume_musica_partida
	# esconde as telas
	start_menu.hide()
	game_over_menu.hide()

func get_temporizador() -> Temporizador:
	return temporizador

# ---------------------------------
# Updates Externos
# ---------------------------------
func ajustar_faltando(qtd_mudas : int, qtd_pinos : int, qtd_lixo : int) -> void:
	barra_progresso.ajustar_faltando(qtd_mudas, qtd_pinos, qtd_lixo)

## atualiza barra de progresso de quantas mudas tem que ser plantadas
func update_mudas_faltando(qtd_mudas : int) -> void:
	barra_progresso.update_mudas_faltando(qtd_mudas)

## atualiza barra de progresso de quantas arvores tem que ser cortadas
func update_arvores_invasoras_faltando(qtd_pinos : int) -> void:
	barra_progresso.update_pinos_faltando(qtd_pinos)

## atualiza barra de progresso de quantos lixos tem que ser recolhidos
func update_lixo_faltando(qtd_lixo : int) -> void:
	barra_progresso.update_lixo_faltando(qtd_lixo)

## atualiza a label do cronometro
func update_tempo(texto : String) -> void:
	label_cronometro.text = texto

# ---------------------------------
# Menu de comeco de partida, contando tempo ate comecar
# ---------------------------------
func comecar_contar() -> void:
	# -- pre contar --
	is_comecando_contar = true
	start_menu.show()
	# comeca a barra de progresso
	barra_progresso.comecar(start_count_num)
	# -- contar --
	var numeros = start_count_num
	while (numeros > 0):
		start_label_count.text = str(numeros)
		await get_tree().create_timer(1.0, true).timeout
		numeros -= 1
	# -- pos contar --
	start_menu.hide()
	is_comecando_contar = false
	# comecar a partida
	comecar_partida()

# ---------------------------------
# Comecar Partida
# ---------------------------------
func comecar_partida() -> void:
	emit_signal("partida_comecando")
	# toca a musica do level
	audio_player_musica.play()
	# comeca o temporizador
	temporizador.comecar()

# ---------------------------------
# Menu de GameOver
# ---------------------------------
func show_tela_fim(tipo : Tipo_fim) -> void:
	# para a musica (tb para restart do level n comecar tocando a musica)
	audio_player_musica.stop()
	
	# mostra o menu de fim de jogo
	game_over_menu.show()
	game_over_btns.hide()
	
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
	
	# espera um tempo para mostrar os botoes
	await tween.finished
	#await get_tree().create_timer(1.0, true).timeout
	game_over_btns.show()
	game_over_btn_replay.grab_focus()
	
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

# ---------------------------------
# Pausar Partida
# ---------------------------------
func pausar() -> void:
	if is_comecando_contar: return # nao pausar se estiver na contagem inicial
	if not get_tree().paused: # nao esta pausado
		_pausar()

func despausar() -> void:
	if is_comecando_contar: return # nao pausar se estiver na contagem inicial
	if get_tree().paused: # esta pausado
		_despausar()

func toggle_pausar() -> void:
	# nao pausar se estiver na contagem inicial
	if is_comecando_contar: return
	
	# nao esta pausado
	if not get_tree().paused:
		_pausar()
	else: # ja esta pausado
		_despausar()

func _pausar() -> void:
	if despausado_recente: return # se tiver despausado recente -> nao pause
	get_tree().paused = true
	pause_menu.show()
	pause_menu_btn_jogo.grab_focus()
	
func _despausar() -> void:
	pause_menu.hide()
	get_tree().paused = false
	# se foi despausado recentemente
	despausado_recente = true
	get_tree().create_timer(0.5, true).timeout.connect(func(): despausado_recente = false )

func _on_button_jogo_pressed() -> void:
	_despausar()

func _on_button_restart_pressed() -> void:
	_replay()

func _on_button_menu_pressed() -> void:
	_goto_menu()

# ---------------------------------
# Funcoes de Trocar de Cena
# ---------------------------------
func _goto_menu() -> void:
	get_tree().paused = false
	SceneManager.goto_menu()
	
func _replay() -> void:
	get_tree().paused = false
	SceneManager.restart_level()
