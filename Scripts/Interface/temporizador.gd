extends Node
class_name Temporizador

signal fim_tempo

## segundo que duracao da partida
var tempo_restante: float = 60.0

var cronometro_ativo: bool = false

@onready var hud : Hud = get_parent()

func _ready() -> void:
	# pausa o cronometro enquanto get_tree().pause = true
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)

func set_duracao(valor : int) -> void:
	tempo_restante = float(valor)
	atualizar_cronometro()

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

func atualizar_cronometro():
	var minutos: int = int(tempo_restante) / 60
	var segundos: int = int(tempo_restante) % 60
	var texto_tempo : String = str(minutos).pad_zeros(2) + ":" + str(segundos).pad_zeros(2)
	hud.update_tempo(texto_tempo)

func acabar_tempo():
	cronometro_ativo = false
	# emite signal de fim do tempo
	emit_signal("fim_tempo")
