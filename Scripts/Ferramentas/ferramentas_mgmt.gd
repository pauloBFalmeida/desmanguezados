extends Node2D
class_name FerramentaMgmt

signal pegou_ferramenta
signal jogou_ferramenta

var locais_plantar_colecao : LocalPlantarColecao
var tilemaps_chao : TileMapsChao
var level : Level

@export var mudas_referencias : Array[PackedScene]
@export var dropar_offset_jogador := Vector2(-15, 40)

var ferramentas_mao_jogadores : Dictionary[Jogador, Ferramenta]

@onready var jogar_ferramenta_mgmt := $JogarFerramentaMgmt

func _ready() -> void:
	# passa a referencia do FerramentaMgmt para todas as ferramentas
	for child in get_children():
		if child.is_in_group("Ferramentas"):
			var ferramenta : Ferramenta = child
			ferramenta.set_ferramenta_mgmt(self)
	# ajusta o jogar ferramenta mgmt
	jogar_ferramenta_mgmt.set_ferramenta_mgmt(self)

func set_tilemaps_chao(_tilemaps_chao : TileMapsChao) -> void:
	tilemaps_chao = _tilemaps_chao

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
	emit_signal("pegou_ferramenta", jogador, ferramenta)
	
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

func jogador_dropar_ferramenta(jogador : Jogador, ferramenta : Ferramenta, 
								global_pos_ferramenta : Vector2 = Vector2.ZERO) -> void:
	_retirar_ferramenta_jogador(jogador, ferramenta)
	# aparece de volta (visivel no chao)
	ferramenta.show_ferramenta()
	
	# se nao escolheu o lugar -> posiciona perto do jogador
	if global_pos_ferramenta.is_zero_approx():
		# posiciona ferramenta no chao perto do jogador
		global_pos_ferramenta = jogador.global_position + dropar_offset_jogador
	# posiciona ferramenta no chao
	posicionar_ferramenta(ferramenta, global_pos_ferramenta)

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

func posicionar_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

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
