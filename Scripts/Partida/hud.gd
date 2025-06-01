extends Control
class_name Hud

@onready var label_qtd_mudas := $LabelMudas
@onready var label_cronometro := $LabelTempo
@onready var sprite_fim_jogo := $ImagemFim

enum Tipo_fim {DERROTA_TEMPO, VITORIA_SUJO, VITORIA_LIMPO}

@export var imagens_fim_jogo : Dictionary[Tipo_fim, CompressedTexture2D]

func _ready() -> void:
	# esconde a tela de fim de jogo
	sprite_fim_jogo.hide()

## atualiza a label que conta quantas mudas tem que ser plantadas
func update_mudas(qtd_mudas : int) -> void:
	label_qtd_mudas.text = "Quantidade de Árvores a serem plantadas: " + str(qtd_mudas)

## atualiza a label do cronometro
func update_tempo(texto : String) -> void:
	label_cronometro.text = texto

func show_tela_fim(tipo : Tipo_fim) -> void:
	# ajusta a imagem dependendo do tipo de fim de jogo
	sprite_fim_jogo.texture = imagens_fim_jogo[tipo]
	# mostra a imagem
	sprite_fim_jogo.show()
	
	# TODO: fazer algo especial para cada tela ?
	match tipo:
		Tipo_fim.DERROTA_TEMPO:
			pass
		Tipo_fim.VITORIA_SUJO:
			pass
		Tipo_fim.VITORIA_LIMPO:
			pass
			
