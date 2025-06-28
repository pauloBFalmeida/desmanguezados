extends Plantar

func iniciar(plantar : Plantar) -> void:
	layer_acao = plantar.layer_acao
	tipo_ferramenta = Ferramenta_tipo.PLANTAR_UNICO
	duracao_cooldown = plantar.duracao_cooldown
	acontecer_offset = plantar.acontecer_offset
	sons = plantar.sons.duplicate(true)
	
	super._ready()

# override para _ready() nao fazer nada -> ja que vamos usar o iniciar
func _ready() -> void:
	pass

func usar_ferramenta(alvo : Node2D, jogador : Jogador) -> void:
	super.usar_ferramenta(alvo, jogador)
