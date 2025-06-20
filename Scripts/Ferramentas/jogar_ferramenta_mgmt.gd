extends Node
class_name JogarFerramentaMgmt

var ferramenta_mgmt : FerramentaMgmt

var sprite_chao_ref := "res://Cenas/Ferramentas/throw_sprite_chao.tscn"

## distancia maxima que a ferramenta via ser jogada
@export var max_distancia : float = 450.0
## curva de como crece a distancia ao segurar por segundo
@export var distancia_por_tempo : Curve
## velocidade da ferramenta enquanto voa
@export var velocidade_ferramenta : float = 350.0
## multiplicador de velocidade da ferramenta pelo progress_ratio curva de voo
@export var velocidade_ferramenta_na_curva : Curve
## multiplicador de velocidade da ferramenta pelo progress_ratio curva de voo
@export var curvatura_jogar_por_eixo : Curve
# dict de followpaths para cada ferramenta com curva de voo
var ferramentas_jogadas_followpaths : Dictionary[Ferramenta, PathFollow2D]
var previsao_paths : Dictionary[Jogador, Path2D]
var previsao_subitens : Dictionary[Path2D, Dictionary]

@export var linha_width : float = 8.0
@export var linha_width_curve : Curve

func _process(delta: float) -> void:
	_processar_ferramentas_jogadas(delta)

func set_ferramenta_mgmt(_ferram_mgmt : FerramentaMgmt) -> void:
	ferramenta_mgmt = _ferram_mgmt

# charge de [0.0, 1.0] para quanto porcento esta carregado 
func segurando(jogador : Jogador, 
					direcao : Vector2, 
					charge : float) -> void:
	var distancia := max_distancia * distancia_por_tempo.sample(charge)
	var global_end_pos := jogador.global_position + (direcao * distancia)
	
	# jogador nao tem uma curva de previsao ainda -> criar uma
	if not previsao_paths.has(jogador):
		_montar_previsao(jogador)
	
	# updata a curva
	_update_curva_previsao(previsao_paths[jogador], global_end_pos)

func previsao_exist(jogador : Jogador) -> bool:
	return previsao_paths.has(jogador)

func jogar(jogador : Jogador, ferramenta : Ferramenta) -> void:
	# curva de previsao do jogador -- vira --> curva de lancamento
	var path = previsao_paths[jogador]
	previsao_paths.erase(jogador) # remove da lista de previsao
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
func limpar_predicao(jogador : Jogador) -> void:
	if previsao_paths.has(jogador):
		var path = previsao_paths[jogador] # pega o path
		# apaga os sub-itens
		if previsao_subitens.has(path):
			previsao_subitens.erase(path)
		# apaga a curva de path
		previsao_paths.erase(jogador)
		path.queue_free() # libera a memoria


# -
# Privadas
#- 

func _montar_previsao(jogador : Jogador) -> void:
	# criar o path da curva de jogar
	var path = _criar_curva()
	jogador.add_child(path)
	previsao_paths[jogador] = path
	# --- criar os subitens ---
	previsao_subitens[path] = {} # cria um dict novo
	var subitens = previsao_subitens[path]
	# criar linha de arremesso
	var linha = _criar_visual(jogador)
	path.add_child(linha)
	subitens["linha"] = linha
	# criar sprite do fim da curva 
	var sprite_fim = _criar_visual_queda(jogador)
	path.add_child(sprite_fim)
	subitens["sprite_fim"] = sprite_fim
	# criar sprite de fora da tela, em cima do jogador
	var sprite_fora = _criar_visual_queda(jogador)
	path.add_child(sprite_fora)
	subitens["sprite_fora"] = sprite_fora
	# posicao logo em cima do jogador
	sprite_fora.position = path.curve.get_point_position(0) + Vector2(0, -60)
	sprite_fora.mostrar_invalido()
	sprite_fora.hide()


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

func _criar_curva() -> Path2D:
	# cria o caminho para jogar a ferramenta
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.z_index = 30 # bota na frente de tudo
	
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
	var aux_size = final_pos.x / final_pos.length() # quantidade no eixo horizontal
	aux_size = abs(aux_size) * 0.7 # aux size comparado com o ponto final
	var aux_pos = final_pos * aux_size
	
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
	_update_visual(path, 
						previsao_subitens[path]["linha"],
						previsao_subitens[path]["sprite_fim"],
						previsao_subitens[path]["sprite_fora"] )

func _criar_visual(jogador : Jogador) -> Line2D:
	# criar linha
	var linha := Line2D.new()
	# grossura
	linha.width = linha_width
	linha.width_curve = linha_width_curve
	# -- Cor --
	var jogador_cor = jogador.theme_color
	# cria as cores
	var cor_comeco := Color(jogador_cor, 0.0)
	var cor_meio   := Color(jogador_cor, 1.0)
	var cor_final  := Color(jogador_cor, 0.8)
	# mais escuro
	cor_final.v  = 0.8
	# ajusta no gradiente
	linha.gradient = Gradient.new()
	linha.gradient.set_color(0, cor_comeco)
	linha.gradient.set_color(1, cor_final)
	# add cor do meio em 25% do comeco do grad 
	linha.gradient.add_point(0.25, cor_meio)
	
	return linha

func _criar_visual_queda(jogador : Jogador) -> ThrowSpriteChao:
	# criar imagem
	var sprite_chao = load(sprite_chao_ref)
	var sprite : ThrowSpriteChao = sprite_chao.instantiate()
	# cor
	sprite.modulate = jogador.theme_color
	return sprite

func _update_visual(path : Path2D, linha : Line2D, 
						sprite_fim : ThrowSpriteChao, 
						sprite_fora : ThrowSpriteChao) -> void:
	var points = path.curve.get_baked_points()
	linha.points = points
	
	## ==> Essa parte n deu certo :/ <==
		## TODO: arrumar essa parte de se a sprite_fim estiver fora da tela
		## 		esconder sprite_fim, e mostrar a sprite_fora
		##		senao: mostrar a sprite_fora, esconder sprite_fim
		## 		
		##		dps de arrumar: remover sprite_fora.mostrar() / esconder() do resto do codigo
	## se estiver fora da tela -> mostre X no jogador
	#if sprite_fim.is_fora_tela():
		#sprite_fora.mostrar()
		#return # para aqui, n precisa verificar se a queda eh valida
	## se for visivel -> mostre no final da curva
	#sprite_fora.esconder()
	
	# posicao de queda (fim da curva)
	var pos_queda = path.curve.get_point_position(1)
	sprite_fim.position = pos_queda
	# se a posicao que for cair for invalida -> mostra invalido
	var global_pos_queda = path.global_position + pos_queda
	if not ferramenta_mgmt.is_global_pos_valida_ferramenta(global_pos_queda):
		sprite_fim.mostrar_invalido()
		sprite_fora.mostrar()
	else: # se for valida -> mostrar valido
		sprite_fim.mostrar_valido()
		sprite_fora.esconder()

## processar as ferramentas sendo jogadas
func _processar_ferramentas_jogadas(delta : float) -> void:
	# para cada followpath de ferramenta sendo jogada
	for ferramenta: Ferramenta in ferramentas_jogadas_followpaths.keys():
		var path_follow = ferramentas_jogadas_followpaths[ferramenta]
		var prog = velocidade_ferramenta * velocidade_ferramenta_na_curva.sample_baked(path_follow.progress_ratio)
		path_follow.progress += prog * delta
		# se chegou no fim do percurso
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			_ferramenta_fim(ferramenta, path_follow)

## chamar quando a ferramenta cai no chao depois de ser jogada
func _ferramenta_fim(ferramenta : Ferramenta, path_follow : Node2D) -> void:
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
	if not ferramenta_mgmt.is_global_pos_valida_ferramenta(global_pos_ferramenta):
		# posiciona no comeco de onde foi lancada
		global_pos_ferramenta  = path.global_position
		#global_pos_ferramenta += path.curve.get_point_position(0) # primeiro ponto eh na origem
		global_pos_ferramenta += ferramenta_mgmt.dropar_offset_jogador
		# fade in na ferramenta
		ferramenta_mgmt.fade_in_ferramenta(ferramenta, 0.8)
	
	# posiciona ferramenta no chao
	ferramenta_mgmt.posicionar_ferramenta(ferramenta, global_pos_ferramenta)
	
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# deleta a curva e os filhos
	path.queue_free()
