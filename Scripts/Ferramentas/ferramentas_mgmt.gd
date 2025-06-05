extends Node2D
class_name FerramentaMgmt

var locais_plantar_colecao : LocalPlantarColecao
var level : Level

@export var mudas_referencias : Array[PackedScene]

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for ferramenta : Ferramenta in get_children():
		ferramenta.ferramenta_mgmt = self

func jogador_pegar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		locais_plantar_colecao.mostrar()
	
	ferramenta.hide_ferramenta()
	
	remove_child(ferramenta)
	jogador.add_child(ferramenta)

func jogador_soltar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		locais_plantar_colecao.esconder()
	
	jogador.remove_child(ferramenta)
	add_child(ferramenta)
	
	ferramenta.show_ferramenta()
	
	# spawn a ferramenta no chao
	var pos_ferramenta = jogador.global_position + Vector2(-15, 40)
	_position_ferramenta(ferramenta, pos_ferramenta)

func _position_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

func plantar_muda(local_plantar : Node2D) -> void:
	locais_plantar_colecao.remove_local_plantar(local_plantar)
	
	var muda_ref = mudas_referencias.pick_random()
	var muda : Arvore = muda_ref.instantiate()
	
	muda.global_position = local_plantar.global_position
	level.plantada_arvore_nativa(muda)
	
	
