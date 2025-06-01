class_name Level
extends Node

@export var arvores_colecao : Node
@export var lixos_colecao : Node
@export var locais_plantar_colecao : Node2D
@export var ferramenta_mgmt : FerramentaMgmt
@export var fim_jogo : Node
@export var hud : Hud

@export var qtd_mudas_para_plantar : int

#var qtd_mudas_para_plantar : int = 0
var qtd_arvores_invasoras : int = 0
var qtd_arvores_nativas : int = 0

var qtd_lixo : int = 0

func _ready() -> void:
	# ferramentas
	locais_plantar_colecao.hide()
	ferramenta_mgmt.level = self
	ferramenta_mgmt.locais_plantar_colecao = locais_plantar_colecao
	# 
	ajustar_arvores()
	ajustar_lixo()
	ajustar_locais_plantar()
	fim_jogo.fim_tempo.connect(_fim_tempo)

# ----- Fim de Jogo -----
func _fim_tempo() -> void:
	if qtd_arvores_nativas < qtd_mudas_para_plantar:
		print("perdeu por tempo")
		#fim_jogo.game_over()
	else: # quantidade suficiente de mudas plantadas
		if qtd_lixo > 0: # deixou lixo
			print("ganhou, mas mangue sujo")
		else: # limpou tudo
			print("ganhou, com mangue limpo")

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
		else: # arvore nativa
			#qtd_arvores_nativas += 1
			arvore.cortada.connect(_cortada_arvore_nativa)

func plantada_arvore_nativa(arvore : Arvore) -> void:
	arvores_colecao.add_child(arvore)
	qtd_arvores_nativas += 1
	arvore.cortada.connect(_cortada_arvore_nativa)
	update_hud_mudas()

func _cortada_arvore_invasora() -> void:
	qtd_arvores_invasoras -= 1
	update_hud_mudas()

func _cortada_arvore_nativa() -> void:
	qtd_arvores_nativas -= 1
	update_hud_mudas()
	# TODO: penalizacao por cortar arvore nativa

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
