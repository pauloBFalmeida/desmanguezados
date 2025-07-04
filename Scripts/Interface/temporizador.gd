extends Node
class_name Temporizador

signal fim_tempo

## segundo que duracao da partida
var tempo_restante: float = 60.0

var cronometro_ativo: bool = false

@onready var hud : Hud = get_parent()
@onready var audio_player_final_tempo := $AudioPlayerFinalTempo

func _ready() -> void:
	# pausa o cronometro enquanto get_tree().pause = true
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	# audio do final da partida
	audio_player_final_tempo.stop() # ter certeza que nao esteja tocando
	audio_player_final_tempo.volume_db = Globais.volume_efeitos_partida

func set_duracao(valor : int) -> void:
	tempo_restante = float(valor)
	atualizar_cronometro()

## retorna o tempo do level, arredondando para cima (24.6 -> 25)
func get_tempo() -> int:
	return ceil(tempo_restante)

func comecar():
	# Inicia o cronômetro
	cronometro_ativo = true

func parar():
	cronometro_ativo = false

func _process(delta):
	# Se o tempo chegar a 0 - Fim do jogo
	if cronometro_ativo:
		tempo_restante -= delta
		if tempo_restante <= 0:
			
			acabar_tempo()
			
		else:
			atualizar_cronometro()
			if tempo_restante < 11:
				tocar_audio_final_tempo()

func atualizar_cronometro():
	var minutos: int = int(tempo_restante) / 60
	var segundos: int = int(tempo_restante) % 60
	var texto_tempo : String = str(minutos).pad_zeros(2) + ":" + str(segundos).pad_zeros(2)
	hud.update_tempo(texto_tempo)

func acabar_tempo():
	cronometro_ativo = false
	audio_player_final_tempo.stop() # parar o audio
	# emite signal de fim do tempo
	emit_signal("fim_tempo")

func tocar_audio_final_tempo() -> void:
	# se ja estiver tocando, nao faca nada
	if audio_player_final_tempo.playing: return
	
	# comece a tocar o audio
	audio_player_final_tempo.play()
