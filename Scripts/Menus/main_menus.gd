extends Node

@onready var audio_player_musica_menu := $AudioStreamPlayerMusicaMenu

@onready var logos_inicio := $LogosInicio
@onready var logos_anim   := $LogosInicio/AnimationPlayerLogos

func _ready() -> void:
	# faz o load do save do game (se ja tiver feito, nao sobrescreve)
	SaveManager.load_game(false)
	
	# cuida da animacao de intro
	await mostrar_intro() # espera a animacao acabar
	logos_inicio.hide()
	
	# faz com que o audio player nao seja removido na troca de menus
	remove_child(audio_player_musica_menu)
	add_child(audio_player_musica_menu, false, Node.INTERNAL_MODE_BACK)
	# comecar o audio
	audio_player_musica_menu.volume_db = Globais.volume_musica_menu
	audio_player_musica_menu.play(2.0) # pula os 2 segundos de silencio do comeco

func update_volume_musica_menu() -> void:
	audio_player_musica_menu.volume_db = Globais.volume_musica_menu

func mostrar_intro() -> void:
	# nao eh para remover as intros -> acabe
	if Globais.remov_logo_intro: return
	
	# se esta abrindo o jogo pela primeira vez
	if Globais.is_abrindo_jogo():
		logos_inicio.show()
		# play animacao
		logos_anim.play("show")
		await logos_anim.animation_finished
