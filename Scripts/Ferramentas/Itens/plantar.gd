extends Ferramenta
class_name Plantar

func _ready() -> void:
	super() # chama _ready da classe Ferramenta

func usar_ferramenta(alvo : Node2D, jogador : Jogador) -> void:
	# se estiver no cooldown -> nao faca nada
	if is_on_cooldown: return
	# se nao for local de plantar -> nao faca nada
	if not alvo.is_in_group("LocalPlantar"): 
		usar_generico(alvo)
		return
	
	super.aplicar_cooldown()
	
	# espera um pouco fazer as coisas acontecerem
	desativar(alvo)
	await get_tree().create_timer(acontecer_offset).timeout
	
	var local_plantar : Node2D = alvo
	# planta
	plantar(local_plantar)
	
	# tocar som
	super.tocar_som(Ferramenta.Som_tipo.ACERTO)

func plantar(local_plantar : Node2D) -> void:
	var local_plantar_colecao : LocalPlantarColecao = local_plantar.get_parent()
	local_plantar_colecao.plantar_muda(local_plantar)
	#ferramenta_mgmt.plantar_muda(local_plantar)
