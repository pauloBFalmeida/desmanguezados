extends Node2D
class_name FerramentaMgmt

signal pegou_ferramenta
signal jogou_ferramenta

var tilemaps_chao : TileMapsChao
var locais_plantar_colecao : LocalPlantarColecao
var level : Level

@export var mudas_referencias : Array[PackedScene]
@export var dropar_offset_jogador := Vector2(-15, 40)

var ferramentas_level : Array[Ferramenta]
var jogadores_segurando_ferramenta : Dictionary[Jogador, Ferramenta]

@onready var jogar_ferramenta_mgmt := $JogarFerramentaMgmt

var plantar_unico_ref := preload("res://Cenas/Ferramentas/Itens/PlantarUnico.tscn")
var plantar_unico : Plantar

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for child in get_children():
		if child.is_in_group("Ferramentas"):
			var ferramenta : Ferramenta = child
			ferramenta.set_ferramenta_mgmt(self)
			ferramentas_level.append(ferramenta)
	# ajusta o jogar ferramenta mgmt
	jogar_ferramenta_mgmt.set_ferramenta_mgmt(self)

func set_tilemaps_chao(_tilemaps_chao : TileMapsChao) -> void:
	tilemaps_chao = _tilemaps_chao

func set_locais_plantar_colecao(_locais_plantar_colecao : LocalPlantarColecao) -> void:
	locais_plantar_colecao = _locais_plantar_colecao
	locais_plantar_colecao.plantar.connect(plantar_muda)

# -----------------------------------------------
# Plantar Muda
# -----------------------------------------------
#func plantar_muda(local_plantar : Node2D) -> void:
	## instancia uma muda
	#var muda_ref = mudas_referencias.pick_random()
	#var muda : Arvore = muda_ref.instantiate()
	## ajustes para muda funcionar
	#muda.global_position = local_plantar.global_position
	#level.plantada_arvore_nativa(muda)
	## retira o local de plantar para colocar a muda
	#locais_plantar_colecao.remove_local_plantar(local_plantar)
	
func plantar_muda(global_pos : Vector2) -> void:
	# instancia uma muda
	var muda_ref = mudas_referencias.pick_random()
	var muda : Arvore = muda_ref.instantiate()
	# ajustes para muda funcionar
	muda.global_position = global_pos
	level.plantada_arvore_nativa(muda)

# -----------------------------------------------
# Pegar e Largar ferramenta
# -----------------------------------------------
func jogador_pegar_ferramenta(jogador : Jogador, ferramenta : Ferramenta) -> void:
	emit_signal("pegou_ferramenta", jogador, ferramenta)
	
	jogadores_segurando_ferramenta [jogador] = ferramenta
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		locais_plantar_colecao.mostrar()
		# cria a ferramenta de uso unico
		_criar_ferramenta_plantar_unico(jogador, ferramenta)
	
	# esconde
	ferramenta.hide_ferramenta()
	
	# coloca ferramenta como filho do jogador
	ferramenta.get_parent().remove_child(ferramenta)
	jogador.add_child(ferramenta)
	
	# coloca colado no jogador, para ter o som no local certinho
	ferramenta.position = Vector2.ZERO

func jogador_dropar_ferramenta(jogador : Jogador, ferramenta : Ferramenta, 
								global_pos_ferramenta : Vector2 = Vector2.ZERO) -> void:
	_retirar_ferramenta_jogador(jogador, ferramenta)
	
	# lidar com plantar uso unico -> deve parar o resto da funcao
	if _lidar_dropar_plantar_unico(jogador, ferramenta):
		return
	
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# se nao escolheu o lugar -> posiciona perto do jogador
	if global_pos_ferramenta.is_zero_approx():
		# posiciona ferramenta no chao perto do jogador
		global_pos_ferramenta = jogador.global_position + dropar_offset_jogador
	# posiciona ferramenta no chao
	posicionar_ferramenta(ferramenta, global_pos_ferramenta)

func _retirar_ferramenta_jogador(jogador : Jogador, ferramenta : Ferramenta) -> void:
	jogadores_segurando_ferramenta.erase(jogador)
	
	# esconde as setas dos locais de plantar se ninguem estiver segurando plantar
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		# se ainda tem algum jogador segurando uma ferramenta tipo PLANTAR
		var ainda_segurando : bool = false 
		for _ferram in jogadores_segurando_ferramenta .values():
			if (_ferram.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR or 
			_ferram.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR_UNICO):
				ainda_segurando = true
				break
		# se nao tiver ninguem segurando -> esconda
		if not ainda_segurando:
			locais_plantar_colecao.esconder()
	
	# tira de filho do jogador e devolve pro ferramenta_mgmt
	jogador.remove_child(ferramenta)
	add_child(ferramenta)

func posicionar_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

# -----------------------------------------------
# Uso Unico
# -----------------------------------------------
func _criar_ferramenta_plantar_unico(jogador : Jogador, ferramenta_plantar : Plantar) -> void:
	# se ja existe uma ferramenta -> nao crie outra
	if plantar_unico and is_instance_valid(plantar_unico) and plantar_unico.is_inside_tree():
		# se for ser deletado -> entao crie outro
		if not plantar_unico.is_queued_for_deletion():
			print('nao criar ')
			return
		else:
			print('criar - queued delete')
	
	plantar_unico = plantar_unico_ref.instantiate()
	plantar_unico.iniciar(ferramenta_plantar)
	plantar_unico.set_ferramenta_mgmt(self) # necessario para funcionar
	# esconde a ferramenta mas deixa que o outro jogador possa pegar
	plantar_unico.hide_manter_pegavel_ferramenta()
	# adiciona ao jogador
	jogador.add_child(plantar_unico)

func _deletar_ferramenta_plantar_unico(ferramenta : Ferramenta, criar_outra : bool = true) -> void:
	ferramenta.hide_ferramenta()
	ferramenta.queue_free()
	
	# TODO: esse codigo crasha se os jogadores duplicarem a ferramenta,
	# 		mas fora isso deveria funcionar
	# se nao for para criar outra -> acabe
	#if not criar_outra: return
	
	# -- criar outra ferramenta de plantar uso unico filho do jog com plantar --
	# acha jogador com plantar
	for jog in jogadores_segurando_ferramenta.keys():
		var jog_segurando : Ferramenta = jogadores_segurando_ferramenta[jog]
		# jog esta segurando plantar -> cria outro de uso unico e acabe
		if jog_segurando.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
			_criar_ferramenta_plantar_unico(jog, jog_segurando)
			break

## retorna se o resto da funcao nao deve ser executado 
func _lidar_dropar_plantar_unico(jogador : Jogador, ferramenta : Ferramenta) -> bool:
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR_UNICO:
		_deletar_ferramenta_plantar_unico(ferramenta)
		return true # nao continua a funcao principal (que fez a chamada dessa)
	
	if ferramenta.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR:
		# nao pegaram a de plantar uso unico, continua com o jogador -> deleta uso unico
		if plantar_unico.get_parent() == jogador:
			_deletar_ferramenta_plantar_unico(plantar_unico, false)
	
	# continua a funcao principal (que fez a chamada dessa)
	return false

# -----------------------------------------------
# Jogar / Throw ferramenta
# -----------------------------------------------
# charge de [0.0, 1.0] para quanto porcento esta carregado 
func jogador_throw_ferramenta_segurando(jogador : Jogador, 
										direcao : Vector2, 
										charge : float) -> void:
	jogar_ferramenta_mgmt.segurando(jogador, direcao, charge)
	
func jogador_throw_ferramenta_jogar(jogador : Jogador, ferramenta : Ferramenta) -> void:
	if not jogar_ferramenta_mgmt.previsao_exist(jogador): return
	# lidar com plantar uso unico -> deve parar o resto da funcao
	if _lidar_dropar_plantar_unico(jogador, ferramenta):
		return
	
	emit_signal("jogou_ferramenta", jogador, ferramenta)
	
	# esconde a ferramenta e retira ela da mao do jogador
	ferramenta.hide_ferramenta()
	_retirar_ferramenta_jogador(jogador, ferramenta)
	
	jogar_ferramenta_mgmt.jogar(jogador, ferramenta)

## libera a curva de previsao desse jogador
func jogador_throw_limpar_predicao(jogador : Jogador) -> void:
	jogar_ferramenta_mgmt.limpar_predicao(jogador)

func is_global_pos_valida_ferramenta(global_pos_ferramenta : Vector2) -> bool:
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
