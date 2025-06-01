extends Ferramenta

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D) -> void:
	# se nao for lixo, nao faca nada
	if not body.is_in_group("Lixo"): return
	
	var lixo : Lixo = body
	lixo.recolher()
