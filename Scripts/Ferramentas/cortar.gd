extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D) -> void:
	# se nao for uma arvore, nao faca nada
	if not body.is_in_group("Arvore"): return
	
	var arvore : Arvore = body
	
	arvore.cortar()
