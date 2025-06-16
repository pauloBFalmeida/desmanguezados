extends Node2D
class_name FerramentaMgmt

var locais_plantar_colecao : LocalPlantarColecao
var level : Level

@export var mudas_referencias : Array[PackedScene]

var ferramentas_mao_jogadores : Dictionary[Jogador, Ferramenta]

# lancar ferramentas
@export var velocidade_jogar_ferramenta : float = 350.0
@export var jogar_ferramenta_speed_curve : Curve
var ferramentas_jogadas_followpaths : Dictionary[PathFollow2D, Ferramenta]

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for ferramenta : Ferramenta in get_children():
		ferramenta.set_ferramenta_mgmt(self)


func _physics_process(delta: float) -> void:
	# para cada followpath de ferramenta sendo jogada
	for path_follow: PathFollow2D in ferramentas_jogadas_followpaths.keys():
		path_follow.progress += velocidade_jogar_ferramenta * delta * jogar_ferramenta_speed_curve.sample(path_follow.progress_ratio)
		# se chegou no fim do percurso
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			var ferramenta = ferramentas_jogadas_followpaths[path_follow]
			# aparece de volta (visivel no chao)
			ferramenta.show_ferramenta()
			# remove a curva de ferramenta jogada
			ferramentas_jogadas_followpaths.erase(path_follow)
			# deleta a curva
			var path = path_follow.get_parent()
			path.queue_free()

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


func jogador_soltar(jogador : Jogador, ferramenta : Ferramenta, pos_ferramenta : Vector2) -> void:
	_retirar_ferramenta_jogador(jogador, ferramenta)
	
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	# posiciona ferramenta no chao
	_position_ferramenta(ferramenta, pos_ferramenta)

func _retirar_ferramenta_jogador(jogador : Jogador, ferramenta : Ferramenta) -> void:
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

func _position_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos


func jogador_jogar_ferramenta(jogador: Jogador, ferramenta: Ferramenta, glob_pos_ferramenta: Vector2) -> void:
	# esconde a ferramenta e reitra ela do jogador
	ferramenta.hide_ferramenta()
	_retirar_ferramenta_jogador(jogador, ferramenta)
	# ja posiciona a ferramenta onde ela vai cair
	_position_ferramenta(ferramenta, glob_pos_ferramenta)
	
	# cria o caminho para jogar a ferramenta
	var path := Path2D.new()
	path.curve = Curve2D.new()
	
	# ajeita as posicoes referentes a posicao base da curva
	# ponto inicial eh o jogador
	path.global_position = jogador.global_position
	var start_pos := Vector2.ZERO
	# posicao final eh onde cai a ferramenta
	var final_pos := path.to_local(glob_pos_ferramenta)
	# ponto auxiliar para dar a curvatura (out do ponto inicial)
	var aux_pos = final_pos * 0.7
	aux_pos = aux_pos.rotated(-PI/3)
	# se esta indo para baixo do ponto inicial
	if aux_pos.y > start_pos.y:
		# rotaciona pro outro lado, para ir para cima do ponto inicial
		aux_pos = aux_pos.rotated(2*PI/3)
	path.curve.add_point(start_pos, Vector2.ZERO, aux_pos)
	path.curve.add_point(final_pos)
	
	# cria o que percorre a curva
	var pathFollow := PathFollow2D.new()
	pathFollow.loop = false
	
	# duplica a sprite da ferramenta para colocar no que percorre a curva
	var ferram_sprite : Sprite2D = ferramenta.sprite.duplicate()
	ferram_sprite.material = null # remove a outline
	ferram_sprite.z_index = 20
	
	# adiciona na cena
	add_child(path)
	path.add_child(pathFollow)
	pathFollow.add_child(ferram_sprite)
	
	# salva o path e a ferramenta nesse dict
	ferramentas_jogadas_followpaths[pathFollow] = ferramenta


func plantar_muda(local_plantar : Node2D) -> void:
	locais_plantar_colecao.remove_local_plantar(local_plantar)
	
	var muda_ref = mudas_referencias.pick_random()
	var muda : Arvore = muda_ref.instantiate()
	
	muda.global_position = local_plantar.global_position
	level.plantada_arvore_nativa(muda)
