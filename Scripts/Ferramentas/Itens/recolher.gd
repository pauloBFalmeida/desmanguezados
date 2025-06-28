extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D, jog : Jogador) -> void:
	# se estiver no cooldown -> nao faca nada
	if is_on_cooldown: return
	# se nao for lixo -> nao faca nada
	if not body.is_in_group("Lixo"):
		usar_generico(body)
		return
	
	super.aplicar_cooldown()
	
	# espera um pouco fazer as coisas acontecerem
	desativar(body)
	await get_tree().create_timer(acontecer_offset).timeout

	var lixo : Lixo = body
	lixo.recolher()
	
	# tocar som
	super.tocar_som(Ferramenta.Som_tipo.ACERTO)
