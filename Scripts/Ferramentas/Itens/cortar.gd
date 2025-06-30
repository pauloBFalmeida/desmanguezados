extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(alvo : Node2D, jogador : Jogador) -> void:
	# se estiver no cooldown -> nao faca nada
	if is_on_cooldown: return
	# se nao for uma arvore -> nao faca nada
	if not alvo.is_in_group("Arvore"): 
		usar_generico(alvo)
		return
	
	super.aplicar_cooldown()
	
	# espera um pouco fazer as coisas acontecerem
	desativar(alvo)
	await get_tree().create_timer(acontecer_offset).timeout
	
	var arvore : Arvore = alvo
	arvore.cortar()
	
	# tocar som
	var tipo_som : Ferramenta.Som_tipo 
	tipo_som = Ferramenta.Som_tipo.ACERTO if arvore.is_invasora else Ferramenta.Som_tipo.ERRO
	super.tocar_som(tipo_som)
