extends Node2D
class_name FerramentaMgmt

var locais_plantar_colecao : LocalPlantarColecao
var level : Level

@export var mudas_referencias : Array[PackedScene]

var ferramentas_mao_jogadores : Dictionary[Jogador, Ferramenta]

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for ferramenta : Ferramenta in get_children():
		ferramenta.set_ferramenta_mgmt(self)

func jogador_pegar(jogador : Jogador, ferramenta : Ferramenta) -> void:
	ferramentas_mao_jogadores[jogador] = ferramenta
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		locais_plantar_colecao.mostrar()
	
	# esconde
	ferramenta.hide_ferramenta()
	
	# tira do ferramenta_mgmt e coloca como filho do jogador
	remove_child(ferramenta)
	jogador.add_child(ferramenta)
	
	# coloca colado no jogador, para ter o som no local certinho
	ferramenta.position = Vector2.ZERO

func jogador_soltar(jogador : Jogador, ferramenta : Ferramenta) -> void:
	# 
	ferramentas_mao_jogadores.erase(jogador)
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		# se ainda tem algum jogador segurando uma ferramenta tipo PLANTAR
		var ainda_segurando : bool = false 
		for _ferram in ferramentas_mao_jogadores.values():
			if _ferram.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
				ainda_segurando = true
				break
		# se nao tiver ninguem segurando -> esconda
		if not ainda_segurando:
			locais_plantar_colecao.esconder()
	
	# tira de filho do jogador e devolve pro ferramenta_mgmt
	jogador.remove_child(ferramenta)
	add_child(ferramenta)
	
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# posiciona ferramenta no chao perto do jogador
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
	
	
