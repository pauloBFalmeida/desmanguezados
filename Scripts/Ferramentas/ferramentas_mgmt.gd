extends Node2D
class_name FerramentaMgmt

var locais_plantar_colecao : Node2D
var level : Level

@export var mudas_referencias : Array[PackedScene]

func jogador_pegar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		ferramenta.ferramenta_mgmt = self
		locais_plantar_colecao.show()
	
	ferramenta.hide_ferramenta()
	
	remove_child(ferramenta)
	jogador.add_child(ferramenta)

func jogador_soltar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		locais_plantar_colecao.hide()
	
	jogador.remove_child(ferramenta)
	add_child(ferramenta)
	
	ferramenta.show_ferramenta()
	
	# spawn a ferramenta no chao
	var pos_ferramenta = jogador.global_position + Vector2(-15, 40)
	_position_ferramenta(ferramenta, pos_ferramenta)

func _position_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

func plantar_muda(global_pos : Vector2) -> void:
	var muda_ref = mudas_referencias.pick_random()
	var muda : Arvore = muda_ref.instantiate()
	muda.global_position = global_pos
	level.plantada_arvore_nativa(muda)
