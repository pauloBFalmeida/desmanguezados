class_name Level
extends Node

@export var arvores_colecao : CanvasGroup
@export var lixos_colecao : CanvasGroup
@export var locais_plantar_colecao : LocalPlantarColecao
@export var ferramenta_mgmt : FerramentaMgmt
@export var hud : Hud
@onready var temporizador : Temporizador = hud.get_temporizador()

## duracao da partida em segundos
@export var duracao_partida_segundos : int = 60

var qtd_arvores_invasoras : int = 0 # que existem atualmente no mapa
var qtd_arvores_nativas : int = 0 # que existem atualmente no mapa
var qtd_alvo_arvores_nativas : int = 0 # que queremos ter no mapa no final da partida

var qtd_lixo : int = 0  # que exist atualmente no mapa

var is_fim_partida : bool = false

const local_plantar_ref := preload("res://Cenas/Partida/local_plantar.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and (not is_fim_partida):
		if not get_tree().paused:
			hud.pausar()

func _ready() -> void:
	_ajustar_pause()
	# ferramentas
	locais_plantar_colecao.esconder()
	ferramenta_mgmt.level = self
	ferramenta_mgmt.set_locais_plantar_colecao(locais_plantar_colecao)
	#
	ajustar_objetivos()
	# 
	temporizador.fim_tempo.connect(_fim_partida)
	temporizador.set_duracao(duracao_partida_segundos)
	# contagem inicial para comecar o jogo
	hud.comecar_contar()

func ajustar_objetivos() -> void:
	ajustar_arvores()
	ajustar_lixo()
	ajustar_locais_plantar() # chamar dps de ajustar_arvores()
	ajustar_barra_progresso()

# ----- Fim de Jogo -----
func _fim_partida() -> void:
	# se ja acabou a partida -> nao faca nada
	if is_fim_partida: return
	
	# marca que o jogo acabou
	is_fim_partida = true
	
	# pausa o jogo
	get_tree().set_pause(true)
	
	# salva o score (o tempo pode ter parado antes)
	Globais.score_level(Globais.current_level_id, temporizador.get_tempo())
	
	# -- muda a imagem dependendo das condicoes de final --
	
	if qtd_mudas_necessitam_plantar() > 0: # nao plantou tudo
		hud.show_tela_fim(Hud.Tipo_fim.DERROTA_TEMPO)
	else: # quantidade suficiente de mudas plantadas
		if qtd_lixo > 0: # deixou lixo
			hud.show_tela_fim(Hud.Tipo_fim.VITORIA_SUJO)
		else: # limpou tudo
			hud.show_tela_fim(Hud.Tipo_fim.VITORIA_LIMPO)
	

func verificar_fim() -> void:
	# plantou tudo e recolheu todo o lixo
	if qtd_mudas_necessitam_plantar() <= 0 and qtd_lixo <= 0:
		temporizador.parar() # para de contar o tempo, antes da animacao de fim de jogo
		
		# espera 1 segundo
		await get_tree().create_timer(1.0).timeout
		# acaba a partida
		_fim_partida()

func qtd_mudas_necessitam_plantar() -> int:
	# quantidade de arvores nativas que queremos ter no mapa - qtd que tem atualmente
	return qtd_alvo_arvores_nativas - qtd_arvores_nativas

# ----- HUD -----
func _update_hud_mudas() -> void:
	hud.update_mudas_faltando(qtd_mudas_necessitam_plantar())

func _update_hud_lixo() -> void:
	hud.update_lixo_faltando(qtd_lixo)

func _update_hud_arvores_invasoras() -> void:
	hud.update_arvores_invasoras_faltando(qtd_arvores_invasoras)

func ajustar_barra_progresso() -> void:
	hud.ajustar_faltando(
		qtd_mudas_necessitam_plantar(),
		qtd_arvores_invasoras,
		qtd_lixo
	)

func _ajustar_pause() -> void:
	# set o node Nivel (pai da cena) como processar sempre
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	# set todos os outros nodes como processar exceto no pause
	for node : Node in get_children():
		node.set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	# set HUD (e filhos) como processar sempre
	hud.set_process_mode(Node.PROCESS_MODE_ALWAYS)

# ----- Arvores -----
func ajustar_arvores() -> void:
	for arvore : Arvore in arvores_colecao.get_children():
		if arvore.is_invasora:
			qtd_arvores_invasoras += 1
			arvore.cortada.connect(_cortada_arvore_invasora)
			arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
		else: # arvore nativa
			qtd_arvores_nativas += 1
			arvore.cortada.connect(_cortada_arvore_nativa)
			arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
	_ajustar_arvores_ordem_tela()

func plantada_arvore_nativa(arvore : Arvore) -> void:
	arvores_colecao.add_child(arvore)
	qtd_arvores_nativas += 1
	arvore.cortada.connect(_cortada_arvore_nativa)
	arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
	# update e hud
	_update_hud_mudas()
	# verifica se acabou o round
	verificar_fim()

func _cortada_arvore_invasora() -> void:
	qtd_arvores_invasoras -= 1
	_update_hud_arvores_invasoras()

func _cortada_arvore_nativa() -> void:
	qtd_arvores_nativas -= 1
	# TODO: penalizacao por cortar arvore nativa

func _update_arvore_cortada(arvore : Arvore) -> void:
	# spawn local de plantar no local da arvore cortada
	spawn_local_plantar(arvore.global_position)
	# update e hud
	_update_hud_mudas()

func spawn_local_plantar(global_pos : Vector2) -> void:
	var local_plantar = local_plantar_ref.instantiate()
	local_plantar.global_position = global_pos
	locais_plantar_colecao.add_local_plantar(local_plantar)

# ----- Lixo -----
func ajustar_lixo() -> void:
	for lixo : Lixo in lixos_colecao.get_children():
		qtd_lixo += 1
		lixo.coletado.connect(_coletado_lixo)

func colocado_lixo(lixo : Lixo) -> void:
	lixos_colecao.add_child(lixo)
	qtd_lixo += 1
	lixo.coletado.connect(_coletado_lixo)

func _coletado_lixo() -> void:
	qtd_lixo -= 1
	# update a hud
	_update_hud_lixo()
	# verifica se acabou o round
	verificar_fim()

# ----- Locais para plantar Mudas -----
# chamar dps de ajustar_arvores()
func ajustar_locais_plantar() -> void:
	# quantidade de arvores ja existentes no mapa
	qtd_alvo_arvores_nativas = qtd_arvores_invasoras + qtd_arvores_nativas
	# adiciona a quantidade de locais para plantar mudas
	qtd_alvo_arvores_nativas += locais_plantar_colecao.get_children().size()


# ----- ajustar arvores ordem de quem aparece na frente na tela -----
func _ajustar_arvores_ordem_tela() -> void:
	var arvore_order : Array[Arvore] = []
	for arvore : Arvore in arvores_colecao.get_children():
		arvore_order.append(arvore)
	# sort decrescente por posicao y no mapa
	# 	ou seja, primeiras posicoes da lista sao com maior y
	arvore_order.sort_custom(func(a, b): return a.global_position.y > b.global_position.y)
	
	# maior y, maior index_z, mais na frented
	var curr_order : int = 0
	for arvore in arvore_order:
		arvores_colecao.move_child(arvore, curr_order)
