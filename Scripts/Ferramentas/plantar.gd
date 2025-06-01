extends Ferramenta

var ferramenta_mgmt : FerramentaMgmt

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(body : Node2D) -> void:
	# se nao for local de plantar, nao faca nada
	if not body.is_in_group("LocalPlantar"): return
	
	# planta
	plantar(body.global_position)
	
	# apaga o local de plantar
	body.hide()
	body.queue_free()
	

func plantar(global_pos : Vector2) -> void:
	ferramenta_mgmt.plantar_muda(global_pos)
