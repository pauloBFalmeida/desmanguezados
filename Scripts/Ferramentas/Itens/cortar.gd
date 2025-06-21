extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D) -> void:
	# se estiver no cooldown -> nao faca nada
	if is_on_cooldown: return
	# se nao for uma arvore -> nao faca nada
	if not body.is_in_group("Arvore"): 
		usar_generico(body)
		return
	
	var arvore : Arvore = body
	
	arvore.cortar()
	
	# tocar som
	var tipo_som : Ferramenta.Som_tipo 
	tipo_som = Ferramenta.Som_tipo.ACERTO if arvore.is_invasora else Ferramenta.Som_tipo.ERRO
	super.tocar_som(tipo_som)
	
	super.aplicar_cooldown()
