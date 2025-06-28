extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(alvo : Node2D, jogador : Jogador) -> void:
	# se estiver no cooldown -> nao faca nada
	if is_on_cooldown: return
	# se nao for lixo -> nao faca nada
	if not alvo.is_in_group("Lixo"):
		usar_generico(alvo)
		return
	
	super.aplicar_cooldown()
	
	# espera um pouco fazer as coisas acontecerem
	desativar(alvo)
	await get_tree().create_timer(acontecer_offset).timeout

	var lixo : Lixo = alvo
	lixo.recolher()
	
	# tocar som
	super.tocar_som(Ferramenta.Som_tipo.ACERTO)
