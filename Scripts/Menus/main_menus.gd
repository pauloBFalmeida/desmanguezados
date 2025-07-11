extends Node

@onready var audio_player_musica_menu := $AudioStreamPlayerMusicaMenu

@onready var logo_vulpe := $LogoVulpe

func _ready() -> void:
	if Globais.is_abrindo_jogo():
		logo_vulpe.show()
		# mostra solido por um tempo
		await get_tree().create_timer(1.5).timeout
		# tween
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(logo_vulpe, 'modulate:a', 0.0, 0.7).from_current()
		await tween.finished
	logo_vulpe.hide()
	
	# faz o load do save do game (se ja tiver feito, nao sobrescreve)
	SaveManager.load_game(false)
	
	# faz com que o audio player nao seja removido na troca de menus
	remove_child(audio_player_musica_menu)
	add_child(audio_player_musica_menu, false, Node.INTERNAL_MODE_BACK)
	# comecar o audio
	audio_player_musica_menu.volume_db = Globais.volume_musica_menu
	audio_player_musica_menu.play(2.0) # pula os 2 segundos de silencio do comeco

func update_volume_musica_menu() -> void:
	audio_player_musica_menu.volume_db = Globais.volume_musica_menu
