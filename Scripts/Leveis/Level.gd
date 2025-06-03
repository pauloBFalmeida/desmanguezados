class_name Level
extends Node

@export var arvores_colecao : Node
@export var lixos_colecao : Node
@export var locais_plantar_colecao : LocalPlantarColecao
@export var ferramenta_mgmt : FerramentaMgmt
@export var temporizador : Node
@export var hud : Hud

@export var qtd_mudas_para_plantar : int

#var qtd_mudas_para_plantar : int = 0
var qtd_arvores_invasoras : int = 0
var qtd_arvores_nativas : int = 0

var qtd_lixo : int = 0

const local_plantar_ref := preload("res://Cenas/Partida/local_plantar.tscn")

func _ready() -> void:
	# ferramentas
	locais_plantar_colecao.esconder()
	ferramenta_mgmt.level = self
	ferramenta_mgmt.locais_plantar_colecao = locais_plantar_colecao
	# 
	ajustar_arvores()
	ajustar_lixo()
	ajustar_locais_plantar()
	# 
	temporizador.fim_tempo.connect(_fim_partida)

# ----- Fim de Jogo -----
func _fim_partida() -> void:
	if qtd_arvores_nativas < qtd_mudas_para_plantar:
		hud.show_tela_fim(Hud.Tipo_fim.DERROTA_TEMPO)
	else: # quantidade suficiente de mudas plantadas
		if qtd_lixo > 0: # deixou lixo
			hud.show_tela_fim(Hud.Tipo_fim.VITORIA_SUJO)
		else: # limpou tudo
			hud.show_tela_fim(Hud.Tipo_fim.VITORIA_LIMPO)

func update_hud_mudas() -> void:
	hud.update_mudas(qtd_mudas_para_plantar - qtd_arvores_nativas)

# ----- Locais para plantar Mudas -----
func ajustar_locais_plantar() -> void:
	#for local in locais_plantar_colecao.get_children():
		#qtd_mudas_para_plantar += 1
	update_hud_mudas()

# ----- Arvores -----
func ajustar_arvores() -> void:
	for arvore : Arvore in arvores_colecao.get_children():
		if arvore.is_invasora:
			qtd_arvores_invasoras += 1
			arvore.cortada.connect(_cortada_arvore_invasora)
			arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
		else: # arvore nativa
			#qtd_arvores_nativas += 1
			arvore.cortada.connect(_cortada_arvore_nativa)
			arvore.cortada.connect(_update_arvore_cortada.bind(arvore))

func plantada_arvore_nativa(arvore : Arvore) -> void:
	arvores_colecao.add_child(arvore)
	qtd_arvores_nativas += 1
	arvore.cortada.connect(_cortada_arvore_nativa)
	arvore.cortada.connect(_update_arvore_cortada.bind(arvore))
	update_hud_mudas()

func _cortada_arvore_invasora() -> void:
	qtd_arvores_invasoras -= 1

func _cortada_arvore_nativa() -> void:
	qtd_arvores_nativas -= 1
	# TODO: penalizacao por cortar arvore nativa

func _update_arvore_cortada(arvore : Arvore) -> void:
	update_hud_mudas()
	# spawn local de plantar no local da arvore cortada
	spawn_local_plantar(arvore.global_position) 

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
