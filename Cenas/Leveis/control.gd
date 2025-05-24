extends Control

var tempo_restante: float = 180.0  # 3 minutos em segundos
var cronometro_ativo: bool = false

func _ready():
	# Inicia o cronômetro
	cronometro_ativo = true

func _process(delta):
	if cronometro_ativo:
		tempo_restante -= delta
		if tempo_restante <= 0:
			game_over()
		else:
			atualizar_cronometro()

func atualizar_cronometro():
	var minutos: int = int(tempo_restante) / 60
	var segundos: int = int(tempo_restante) % 60
	$Label.text = str(minutos).pad_zeros(2) + ":" + str(segundos).pad_zeros(2)

func game_over():
	cronometro_ativo = false
	$Label.text = "Game Over"
	# Aqui você pode adicionar lógica para finalizar o jogo ou reiniciar
