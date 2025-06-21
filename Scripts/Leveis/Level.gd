class_name Level
extends Node

@export var arvores_colecao : CanvasGroup
@export var lixos_colecao : CanvasGroup
@export var locais_plantar_colecao : LocalPlantarColecao
@export var ferramenta_mgmt : FerramentaMgmt
@export var temporizador : Temporizador
@export var hud : Hud

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
	ajustar_pause()
	# ferramentas
	locais_plantar_colecao.esconder()
	ferramenta_mgmt.level = self
	ferramenta_mgmt.set_locais_plantar_colecao(locais_plantar_colecao)
	# 
	ajustar_arvores()
	ajustar_lixo()
	ajustar_locais_plantar() # chamar dps de ajustar_arvores()
	# 
	temporizador.fim_tempo.connect(_fim_partida)
	temporizador.set_duracao(duracao_partida_segundos)
	# contagem inicial para comecar o jogo
	hud.comecar_contar()

# ----- Fim de Jogo -----
func _fim_partida() -> void:
	# se ja acabou a partida -> nao faca nada
	if is_fim_partida: return
	
	# marca que o jogo acabou
	is_fim_partida = true
	
	# pausa o jogo
	get_tree().set_pause(true)
	
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
		# espera 1 segundo
		await get_tree().create_timer(1.0).timeout
		# acaba a partida
		_fim_partida()

func qtd_mudas_necessitam_plantar() -> int:
	return qtd_alvo_arvores_nativas - qtd_arvores_nativas

# ----- HUD -----
func update_hud_mudas() -> void:
	hud.update_mudas(qtd_mudas_necessitam_plantar())

func ajustar_pause() -> void:
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

func plantada_arvore_nativa(arvore : Arvore) -> void:
	arvores_colecao.add_child(arvore)
	qtd_arvores_nativas += 1
	arvore.cortada.connect(_cortada_arvore_nativa)
	arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
	# update e hud
	update_hud_mudas()
	# verifica se acabou o round
	verificar_fim()

func _cortada_arvore_invasora() -> void:
	qtd_arvores_invasoras -= 1

func _cortada_arvore_nativa() -> void:
	qtd_arvores_nativas -= 1
	# TODO: penalizacao por cortar arvore nativa

func _update_arvore_cortada(arvore : Arvore) -> void:
	# spawn local de plantar no local da arvore cortada
	spawn_local_plantar(arvore.global_position)
	# update e hud
	update_hud_mudas()

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
	# verifica se acabou o round
	verificar_fim()

# ----- Locais para plantar Mudas -----
# chamar dps de ajustar_arvores()
func ajustar_locais_plantar() -> void:
	# quantidade de arvores ja existentes no mapa
	qtd_alvo_arvores_nativas = qtd_arvores_invasoras + qtd_arvores_nativas
	# adiciona a quantidade de locais para plantar mudas
	qtd_alvo_arvores_nativas += locais_plantar_colecao.get_children().size()
	# update e hud
	update_hud_mudas()
