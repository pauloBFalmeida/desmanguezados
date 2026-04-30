class_name PlantarUnico
extends Plantar

func iniciar(_plantar : Plantar) -> void:
	tipo = Ferramenta_tipo.PLANTAR_UNICO
	# copia a referencia
	if is_instance_valid(_plantar):
		layer_acao = _plantar.layer_acao
		duracao_cooldown = _plantar.duracao_cooldown
		acontecer_offset = _plantar.acontecer_offset
		sons = _plantar.sons.duplicate(true)
	
	super._ready()

# override para _ready() nao fazer nada -> ja que vamos usar o iniciar
func _ready() -> void:
	pass

func usar_ferramenta(alvo : Node2D, jogador : Jogador) -> void:
	super.usar_ferramenta(alvo, jogador)
	# espera terminar de usar a ferramenta
	await cooldown_terminou
	# deletar a de uso unico (largando ela)
	jogador.drop_ferramenta()
