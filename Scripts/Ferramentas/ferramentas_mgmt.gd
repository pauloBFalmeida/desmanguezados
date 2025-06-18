extends Node2D
class_name FerramentaMgmt

var locais_plantar_colecao : LocalPlantarColecao
var tilemaps_chao : TileMapsChao
var level : Level

@export var mudas_referencias : Array[PackedScene]
@export var dropar_offset_jogador := Vector2(-15, 40)

var ferramentas_mao_jogadores : Dictionary[Jogador, Ferramenta]


# ---------- lancar ferramentas ---------- 
## distancia maxima que a ferramenta via ser jogada
@export var throw_max_distancia : float = 450.0
## curva de como crece a distancia ao segurar por segundo
@export var throw_distancia_por_tempo : Curve
## velocidade da ferramenta enquanto voa
@export var throw_velocidade_ferramenta : float = 350.0
## multiplicador de velocidade da ferramenta pelo progress_ratio curva de voo
@export var throw_velocidade_ferramenta_na_curva : Curve
# dict de followpaths para cada ferramenta com curva de voo
var ferramentas_jogadas_followpaths : Dictionary[Ferramenta, PathFollow2D]
var throw_previsao_paths : Dictionary[Jogador, Path2D]

@export var linha_width : float = 4.0
@export var linha_width_curve : Curve

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for ferramenta : Ferramenta in get_children():
		if ferramenta.is_in_group("Ferramentas"):
			ferramenta.set_ferramenta_mgmt(self)

func _process(delta: float) -> void:
	_processar_ferramentas_jogadas(delta)

# -----------------------------------------------
# Plantar Muda
# -----------------------------------------------
func plantar_muda(local_plantar : Node2D) -> void:
	# instancia uma muda
	var muda_ref = mudas_referencias.pick_random()
	var muda : Arvore = muda_ref.instantiate()
	# ajustes para muda funcionar
	muda.global_position = local_plantar.global_position
	level.plantada_arvore_nativa(muda)
	# retira o local de plantar para colocar a muda
	locais_plantar_colecao.remove_local_plantar(local_plantar)

# -----------------------------------------------
# Pegar e Largar ferramenta
# -----------------------------------------------
func jogador_pegar_ferramenta(jogador : Jogador, ferramenta : Ferramenta) -> void:
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

func jogador_dropar_ferramenta(jogador : Jogador, ferramenta : Ferramenta, pos_ferramenta : Vector2 = Vector2.ZERO) -> void:
	_retirar_ferramenta_jogador(jogador, ferramenta)
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# se nao escolheu o lugar -> posiciona perto do jogador
	if pos_ferramenta.is_zero_approx():
		# posiciona ferramenta no chao perto do jogador
		pos_ferramenta = jogador.global_position + dropar_offset_jogador
	# posiciona ferramenta no chao
	_posicionar_ferramenta(ferramenta, pos_ferramenta)

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

func _posicionar_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

# -----------------------------------------------
# Jogar / Throw ferramenta
# -----------------------------------------------
func jogador_throw_ferramenta_segurando(jogador : Jogador, 
										direcao : Vector2, 
										throw_acumulado_sec : float) -> void:
	var distancia := throw_max_distancia * throw_distancia_por_tempo.sample(throw_acumulado_sec)
	var global_end_pos := jogador.global_position + (direcao * distancia)
	
	# jogador nao tem uma curva de previsao ainda -> criar uma
	if not throw_previsao_paths.has(jogador):
		var path = _criar_curva_throw()
		jogador.add_child(path)
		throw_previsao_paths[jogador] = path
		# criar visual de jogar
		_criar_visual_throw(path, jogador)
	
	# updata a curva
	_update_curva_previsao(throw_previsao_paths[jogador], global_end_pos)

func jogador_throw_ferramenta_jogar(jogador : Jogador, ferramenta : Ferramenta) -> void:
	# sem curva para jogar a ferramenta -> nao faca nada
	if not throw_previsao_paths.has(jogador): return 
	
	# esconde a ferramenta e retira ela da mao do jogador
	ferramenta.hide_ferramenta()
	_retirar_ferramenta_jogador(jogador, ferramenta)

	# curva de previsao do jogador -- vira --> curva de lancamento
	var path = throw_previsao_paths[jogador]
	throw_previsao_paths.erase(jogador) # remove da lista de previsao
	# apaga os filhos
	for child in path.get_children():
		child.queue_free()
	# passa o path da curva para ferramenta_mgmt
	jogador.remove_child(path)
	add_child(path)
	# ajusta para manter a posicao inicial saindo do jogador
	path.global_position = jogador.global_position
	
	# cria a imagem da ferramenta para percorrer a curva
	var pathFollow = _criar_path_follow_ferramenta(ferramenta)
	
	# adiciona na cena
	path.add_child(pathFollow)
	# salva o pathFollow e a ferramenta nesse dict
	ferramentas_jogadas_followpaths[ferramenta] = pathFollow

## libera a curva de previsao desse jogador
func jogador_throw_ferramenta_limpar(jogador : Jogador) -> void:
	if throw_previsao_paths.has(jogador):
		var path = throw_previsao_paths[jogador] # pega o path
		throw_previsao_paths.erase(jogador)
		path.queue_free() # libera a memoria

func _criar_path_follow_ferramenta(ferramenta : Ferramenta) -> PathFollow2D:
	# cria o que percorre a curva
	var pathFollow := PathFollow2D.new()
	pathFollow.loop = false
	
	# duplica a sprite da ferramenta para colocar no que percorre a curva
	var ferram_sprite : Sprite2D = ferramenta.sprite.duplicate()
	ferram_sprite.material = null # remove a outline
	ferram_sprite.z_index = 20
	
	pathFollow.add_child(ferram_sprite)
	
	return pathFollow

func _criar_curva_throw() -> Path2D:
	# cria o caminho para jogar a ferramenta
	var path := Path2D.new()
	path.curve = Curve2D.new()
	
	# ajeita as posicoes referentes a posicao base da curva
	# ponto inicial eh a origem da curva
	var start_pos := Vector2.ZERO
	var final_pos := Vector2.ZERO
	# adiciona os pontos a curva
	path.curve.add_point(start_pos)
	path.curve.add_point(final_pos)
	
	return path

func _update_curva_previsao(path : Path2D, global_pos_fim_curva : Vector2) -> void:
	# posicao final eh onde cai a ferramenta
	var final_pos := path.to_local(global_pos_fim_curva)
	# ponto auxiliar para dar a curvatura (out do ponto inicial)
	var aux_pos = final_pos * 0.7
	
	# faz o ponto aux na curva sempre estar para cima da tela
	if final_pos.x >= 0: # curva para direita
		aux_pos = aux_pos.rotated(-PI/3) # sentido anti horario
	else:
		aux_pos = aux_pos.rotated(PI/3)  # sentido horario
	
	# posicao do ponto aux como out do ponto inicial da curva 
	path.curve.set_point_out(0, aux_pos)
	# posicao do ponto de fim de curva
	path.curve.set_point_position(1, final_pos)
	
	# update visual
	_update_visual_throw(path, path.get_child(0))

func _criar_visual_throw(path : Path2D, jogador : Jogador):
	# criar linha
	var linha := Line2D.new()
	path.add_child(linha)
	
	# grossura
	linha.width = linha_width
	linha.width_curve = linha_width_curve
	# -- Cor --
	var jogador_cor = jogador.theme_color
	#linha.default_color = jogador.theme_color
	# cria as cores
	#var cor_comeco := Color(jogador_cor, 0.0)
	#var cor_meio   := Color(jogador_cor, 0.7)
	#var cor_final  := Color(jogador_cor, 0.1)
	var cor_comeco := Color(jogador_cor)
	var cor_meio   := Color(jogador_cor)
	var cor_final  := Color(jogador_cor)
	cor_comeco.a = 0.0
	cor_meio.a   = 0.7
	cor_final.a  = 0.3
	# ajusta no gradiente
	linha.gradient = Gradient.new()
	linha.gradient.set_color(0, cor_comeco)
	linha.gradient.set_color(1, cor_final)
	linha.gradient.add_point(0.2, cor_meio) # add cor do meioem 20% do comeco

func _update_visual_throw(path : Path2D, linha : Line2D):
	var points = path.curve.get_baked_points()
	linha.points = points
	


## processar as ferramentas sendo jogadas
func _processar_ferramentas_jogadas(delta : float) -> void:
	# para cada followpath de ferramenta sendo jogada
	for ferramenta: Ferramenta in ferramentas_jogadas_followpaths.keys():
		var path_follow = ferramentas_jogadas_followpaths[ferramenta]
		var prog = throw_velocidade_ferramenta * throw_velocidade_ferramenta_na_curva.sample(path_follow.progress_ratio)
		path_follow.progress += prog * delta 
		# se chegou no fim do percurso
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			_ferramenta_fim_throw(ferramenta, path_follow)

## chamar quando a ferramenta cai no chao depois de ser jogada
func _ferramenta_fim_throw(ferramenta : Ferramenta, path_follow : Node2D) -> void:
	if not ferramentas_jogadas_followpaths.has(ferramenta):
		return
	
	# remove a curva de ferramenta jogada
	ferramentas_jogadas_followpaths.erase(ferramenta)
	
	var path : Path2D = path_follow.get_parent()
	# posicao onde a ferramenta caiu no chao
	var global_pos_ferramenta : Vector2
	global_pos_ferramenta  = path.global_position
	global_pos_ferramenta += path.curve.get_point_position(1)
	
	# se a posicao que caiu for invalida -> pega outra posicao
	if not _is_global_pos_valida_ferramenta(global_pos_ferramenta):
		# posiciona no comeco de onde foi lancada
		global_pos_ferramenta  = path.global_position
		#global_pos_ferramenta += path.curve.get_point_position(0) # primeiro ponto eh na origem
		global_pos_ferramenta += dropar_offset_jogador
		# fade in na ferramenta
		fade_in_ferramenta(ferramenta, 0.8)
	
	# posiciona ferramenta no chao
	_posicionar_ferramenta(ferramenta, global_pos_ferramenta)
	
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# deleta a curva e os filhos
	path.queue_free()

func _is_global_pos_valida_ferramenta(global_pos_ferramenta : Vector2) -> bool:
	var on_water : bool = tilemaps_chao.jogador_pos_on_water(global_pos_ferramenta)
	if on_water:
		return false
	
	# nenhum problema -> posicao eh valida
	return true

func fade_in_ferramenta(ferramenta : Ferramenta, duracao : float) -> void:
	# deixa transparente primeiro
	ferramenta.modulate.a = 0.0
	ferramenta.outline_off()
	
	# fade in
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(ferramenta, "modulate:a", 1.0, duracao).from_current()
	# liga a outline de novo
	await tween.finished # espera o tween terminar
	ferramenta.outline_on()
