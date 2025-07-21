extends StaticBody2D
class_name Informacao

signal entrou_area
signal saiu_area

enum Info_tipo {
	PEGAR_FERRAMENTA,
	USAR_FERRAMENTA,
	LARGAR_FERRAMENTA,
	TROCAR_FERRAMENTA,
	JOGAR_FERRAMENTA,
	ACABAR
}
@export var tipo_informacao : Info_tipo

@onready var info := $Info
@onready var label_simbolo : Label = $Info/LabelSimbolo
@onready var label_texto   : Label = $Info/LabelTexto

# salva o pai original (ferramenta)
@onready var original_parent = get_parent()

var curr_jogador : Jogador

var func_sair_area : Callable
var func_entrar_area : Callable


func _ready() -> void:
	info.modulate.a = 0.0
	# comeca o movimento dos textos
	_criar_tween_movimento_info()
	# prepara a info inicial
	info_tipo_preparar()

# ---------------------------------------------------------
# Alteracao de tipo_informacao
# ---------------------------------------------------------
func info_tipo_preparar() -> void:
	match tipo_informacao:
		Info_tipo.PEGAR_FERRAMENTA:
			await entrou_area
			info_tipo_update()

func info_tipo_update() -> void:
	print('tipo_informacao ', tipo_informacao)
	match tipo_informacao:
		Info_tipo.ACABAR:
			queue_free()
		Info_tipo.PEGAR_FERRAMENTA:
			func_entrar_area = info_mostrar
			func_sair_area   = info_esconder_min_time
			_info_pegar_ferramenta()
		Info_tipo.USAR_FERRAMENTA:
			func_entrar_area = Callable()
			func_sair_area   = Callable()
			_info_usar_ferramenta()
		Info_tipo.LARGAR_FERRAMENTA:
			func_entrar_area = Callable()
			func_sair_area   = Callable()
			_info_largar_ferramenta()
		Info_tipo.TROCAR_FERRAMENTA:
			
			pass
		Info_tipo.JOGAR_FERRAMENTA:
			pass

# ---------------------------------------------------------
# Acontecer quando esta em cada tipo_informacao
# ---------------------------------------------------------
func _info_pegar_ferramenta() -> void:
	label_simbolo.text = InputManager.get_text_action(
		curr_jogador.player_id,
		"pickup"
	)
	label_texto.text = "\npara Pegar"
	
	# espera o jogador pegar a ferramenta
	await curr_jogador.pegou_ferramenta
	# avanca para a proxima info
	tipo_informacao = Info_tipo.USAR_FERRAMENTA
	info_tipo_update()

func _info_usar_ferramenta() -> void:
	info_esconder_now()
	# passa para o jogador -> para mostrar quando a ferramente estiver pega
	await _mudar_parent(curr_jogador)
	
	# muda o texto
	label_simbolo.text = InputManager.get_text_action(
		curr_jogador.player_id,
		"interact"
	)
	label_texto.text = "\npara Usar"
	
	# -- decide o que fazer para o jogador --
	var _callable_mostrar    := func(_b): info_mostrar()
	var _callable_esconder   := func(_b): info_esconder()
	var _callable_info_pegar := func(_b):
		await _mudar_parent(original_parent)
		tipo_informacao = Info_tipo.PEGAR_FERRAMENTA
		info_tipo_preparar()
	# quando o jogador pode interagir com algo -> mostra a info
	curr_jogador.area_interacao.body_entered.connect( _callable_mostrar )
	# quando o jogador nao pode interagir com algo -> esconde a info com minimo de tempo
	curr_jogador.area_interacao.body_exited.connect( _callable_esconder )
	# largar ferramenta -> voltar para pegar
	curr_jogador.largou_ferramenta.connect( _callable_info_pegar )
		
	# -- condicoes para proxima info --
	# usar 3 vezes
	for _i in range(3):
		await curr_jogador.usou_ferramenta
	
	# -- ajustar a proxima --
	curr_jogador.area_interacao.body_entered.disconnect( _callable_mostrar )
	curr_jogador.area_interacao.body_exited.disconnect( _callable_esconder )
	curr_jogador.largou_ferramenta.disconnect( _callable_info_pegar )
		
		
	# avanca para a proxima info
	tipo_informacao = Info_tipo.LARGAR_FERRAMENTA
	info_tipo_update()

func _info_largar_ferramenta() -> void:
	info_esconder_now()
	
	# muda o texto
	label_simbolo.text = InputManager.get_text_action(
		curr_jogador.player_id,
		"drop"
	)
	label_texto.text = "\npara Largar"
	
	# -- decide o que fazer para o jogador --
	var tween = create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(info, "modulate:a", 0.0, 2.0)
	tween.tween_interval(3)
	tween.tween_property(info, "modulate:a", 1.0, 2.0)
	tween.tween_interval(3)
	
	# -- esperar as condicoes para terminar --
	await curr_jogador.largou_ferramenta
	
	# avanca para a proxima info
	tipo_informacao = Info_tipo.ACABAR
	info_tipo_update()

# ---------------------------------------------------------
# movimento
# ---------------------------------------------------------
const movimento_distancia : float = 12.0	# y pixels
const movimento_duracao : float = 2.5		# segundos

func _criar_tween_movimento_info() -> void:
	var tween = create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		info,
		"position:y",
		info.position.y + (movimento_distancia),
		movimento_duracao
	).as_relative()
	tween.tween_property(
		info,
		"position:y",
		info.position.y - (movimento_distancia),
		movimento_duracao
	).as_relative()

func _mudar_parent(target_parent : Node) -> void:
	await get_tree().create_timer(1.0).timeout
	get_parent().remove_child(self)
	target_parent.add_child(self)

# ---------------------------------------------------------
# Mostrar ou esconder as informacoes
# ---------------------------------------------------------
func info_mostrar() -> void:
	entrou_area_engine_ms = Time.get_ticks_msec()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		info,
		"modulate:a",
		1.0,
		0.4
	).from_current()

func info_esconder() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		info,
		"modulate:a",
		0.0,
		0.6
	).from_current()

func info_esconder_now() -> void:
	info.modulate.a = 0.0

var esconder_depois_min_time : bool = true
var entrou_area_engine_ms  : int = 0
const min_time_esconder_ms : int = 1500 # 1.5 seg

func info_esconder_min_time() -> void:	
	# enquanto nao passou tempo suficiente -> espere
	while Time.get_ticks_msec() < entrou_area_engine_ms + min_time_esconder_ms:
		await get_tree().create_timer(0.5).timeout
	# se nao for para esconder qnd sair da area
	# 	-entao-> nao eh para esconder (caso essa funcao ainda esteja rolando
	#	-entao-> pare a funcao
	if func_sair_area.is_null(): return
	# esconde
	info_esconder()

# ---------------------------------------------------------
# Area de interacao
# ---------------------------------------------------------
func _atualizar_jogador(jogador : Jogador) -> void:
	# se estiver como filho de jogador -> nao mude a cor
	if get_parent() is Jogador: return
	
	curr_jogador = jogador
	label_simbolo.add_theme_color_override("font_color", jogador.theme_color)
	label_texto.add_theme_color_override("font_color", jogador.theme_color)

func dentro_area_interacao(jogador : Jogador) -> void:
	_atualizar_jogador(jogador)
	emit_signal("entrou_area")
	if not func_entrar_area.is_null():
		func_entrar_area.call()

func saiu_area_interacao(jogador : Jogador) -> void:
	emit_signal("saiu_area")
	if not func_sair_area.is_null():
		func_sair_area.call()
