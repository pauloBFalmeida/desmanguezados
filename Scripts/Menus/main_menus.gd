extends Node

@onready var audio_player_musica_menu := $AudioStreamPlayerMusicaMenu

func _ready() -> void:
	# faz com que o audio player nao seja removido na troca de menus
	remove_child(audio_player_musica_menu)
	add_child(audio_player_musica_menu, false, Node.INTERNAL_MODE_BACK)
	# comecar o audio
	audio_player_musica_menu.play(2.0) # pula os 2 segundos de silencio do comeco
	# faz o load do save do game
	SaveManager.load_game()
