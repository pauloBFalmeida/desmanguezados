extends Ferramenta

var ferramenta_mgmt : FerramentaMgmt

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D) -> void:
	# se nao for local de plantar, nao faca nada
	if not body.is_in_group("LocalPlantar"): return
	
	var local_plantar : Node2D = body
	# planta
	plantar(local_plantar)

func plantar(local_plantar : Node2D) -> void:
	ferramenta_mgmt.plantar_muda(local_plantar)
