extends Level

# Basicamente o codigo inteiro e pra fazer as setas de baixo so aparecerem pro jogador
# que estiver segurando a coisa de plantar
# HAHAHAHA paulo insanity core HAHAHAHAHA

@export var divisor_meio_mapa : Node2D
@export var jogador_top : Jogador
@export var jogador_bot : Jogador

@onready var instrucoes := $Instrucoes

enum Intrucao_tipo {PEGAR_ITEM, USAR_ITEM, JOGAR_ITEM, PEGAR_NOVO_ITEM, CHEGOU_CANTO, TROCAR_ITEM, FIM}

@export var intrucao_jog_top : Dictionary[Intrucao_tipo, Control]
@export var intrucao_jog_bot : Dictionary[Intrucao_tipo, Control]
@onready var jogadores = [jogador_top, jogador_bot]
var curr_instrucao_jog : Dictionary[Jogador, Intrucao_tipo] = {}
var instrucoes_jog : Dictionary[Jogador, Dictionary] = {}
## primeira ferramenta que cada jogador vai pegar
@export var primeira_ferramenta_jog : Dictionary[Jogador, Ferramenta]
##
@export var primeira_usar_jog : Dictionary[Jogador, Node2D]
var instrucoes_feitas_jog : Dictionary[Jogador, Dictionary] = {}

@onready var canto_final := $Instrucoes/CantoFinal

enum Status_segurando {AMBOS, CIMA, BAIXO, NENHUM}
var curr_status := Status_segurando.NENHUM
var prev_status := Status_segurando.NENHUM

func _ready() -> void:
	super()
	hud.partida_comecando.connect( _create_tween_mover )
	ferramenta_mgmt.pegou_ferramenta.connect(jogador_pegou_ferramenta)
	ferramenta_mgmt.jogou_ferramenta.connect(jogador_jogou_ferramenta)
	canto_final.body_entered.connect(chegou_canto_final)
	for jog in jogadores:
		curr_instrucao_jog[jog] = Intrucao_tipo.PEGAR_ITEM
		instrucoes_feitas_jog[jog] = {}
		for instrucao in intrucao_jog_top.keys():
			instrucoes_feitas_jog[jog][instrucao] = false
	instrucoes_jog[jogador_top] = intrucao_jog_top
	instrucoes_jog[jogador_bot] = intrucao_jog_bot
	update_mostrar_intrucoes()
	for jog in primeira_usar_jog.keys():
		var marcador = primeira_usar_jog[jog]
		if marcador.is_in_group("Arvore"):
			var arvore : Arvore = marcador
			arvore.cortada.connect(jogador_usou_ferramenta.bind(jog))
		else:
			var lixo : Lixo = marcador
			lixo.coletado.connect(jogador_usou_ferramenta.bind(jog))
	
	locais_plantar_colecao.comecou_mostrar.connect(ajeitar_locais_plantar_meio_mapa)
	for arvore : Arvore in arvores_colecao.get_children():
		arvore.cortada.connect(ajeitar_locais_plantar_meio_mapa)


func chegou_canto_final(jog : Jogador) -> void:
	marcar_intrucao_feita(jog, Intrucao_tipo.CHEGOU_CANTO)

func marcar_intrucao_feita(jog : Jogador, instrucao : Intrucao_tipo) -> void:
	instrucoes_feitas_jog[jog][instrucao] = true
	prox_instrucao(jog)

func prox_instrucao(jog : Jogador) -> void:
	# intrucao mais inicial que ja foi feita
	var intr_mais_inicial_ano_feita := Intrucao_tipo.PEGAR_ITEM
	for inst in instrucoes_feitas_jog[jog].keys():
		# para na primeira nao feita
		if not instrucoes_feitas_jog[jog][inst]:
			break
		intr_mais_inicial_ano_feita = inst
	# ajusta a proxima intrucao a ser feita
	match intr_mais_inicial_ano_feita:
		Intrucao_tipo.PEGAR_ITEM:
			curr_instrucao_jog[jog] = Intrucao_tipo.USAR_ITEM
		Intrucao_tipo.USAR_ITEM:
			curr_instrucao_jog[jog] = Intrucao_tipo.JOGAR_ITEM
		Intrucao_tipo.JOGAR_ITEM:
			curr_instrucao_jog[jog] = Intrucao_tipo.PEGAR_NOVO_ITEM
		Intrucao_tipo.PEGAR_NOVO_ITEM:
			curr_instrucao_jog[jog] = Intrucao_tipo.CHEGOU_CANTO
		Intrucao_tipo.CHEGOU_CANTO:
			curr_instrucao_jog[jog] = Intrucao_tipo.TROCAR_ITEM
		Intrucao_tipo.TROCAR_ITEM:
			curr_instrucao_jog[jog] = Intrucao_tipo.FIM
		Intrucao_tipo.FIM:
			pass
	update_mostrar_intrucoes()

func jogador_usou_ferramenta(jog : Jogador) -> void:
	marcar_intrucao_feita(jog, Intrucao_tipo.USAR_ITEM)

func jogador_jogou_ferramenta(jog : Jogador, ferramenta : Ferramenta) -> void:
	marcar_intrucao_feita(jog, Intrucao_tipo.JOGAR_ITEM)

func jogador_chegou_canto_final(jog : Jogador) -> void:
	marcar_intrucao_feita(jog, Intrucao_tipo.JOGAR_ITEM)

func jogador_pegou_ferramenta(jog : Jogador, ferramenta : Ferramenta) -> void:
	var jog_id = jogadores.find(jog)
	var outro_jog = jogadores[0] if jog_id == 1 else jogadores[1]
	# jogador pegou o item -> vai pra prox intrucao
	if ferramenta == primeira_ferramenta_jog[jog]:
		marcar_intrucao_feita(jog, Intrucao_tipo.PEGAR_ITEM)
	# jogador pegou a ferramenta do outro jogador -> vai pra prox intrucao
	if ferramenta == primeira_ferramenta_jog[outro_jog]:
		marcar_intrucao_feita(jog, Intrucao_tipo.PEGAR_NOVO_ITEM)
	if (ferramenta != primeira_ferramenta_jog[outro_jog] and 
			ferramenta != primeira_ferramenta_jog[jog]):
		marcar_intrucao_feita(jog, Intrucao_tipo.TROCAR_ITEM)
			

# mostra as instrucoes mais atuais do jogador, e esconde as outras
func update_mostrar_intrucoes() -> void:
	for jog in jogadores:
		# se for o fim -> esconda todas e acabe
		if curr_instrucao_jog[jog] == Intrucao_tipo.FIM:
			for instrucao in instrucoes_jog[jog].values():
				instrucao.hide()
			return
		
		# mostra a mais atual
		for instrucao_t in instrucoes_jog[jog].keys():
			var instrucao = instrucoes_jog[jog][instrucao_t]
			# se for a instrucao atual -> mostre 
			if instrucao_t == curr_instrucao_jog[jog]:
				instrucao.show()
			else: # se nao for -> esconda
				instrucao.hide()

func _create_tween_mover(subindo : int = 1) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		instrucoes, "position:y",
		10 * subindo,	# qntd
		2.0				#duracao
	).from_current()
	tween.finished.connect( _create_tween_mover.bind(-subindo) )

# -----------
# So mostrar o plantar pro jogador verticalmente
# -----------
func _process(delta: float) -> void:
	if curr_status != Status_segurando.NENHUM:
		update_status()
		if curr_status != prev_status:
			update_mostrar()
	prev_status = curr_status
	
func update_status() -> void:
	var cima := false
	var baixo := false
	if is_instance_valid(jogador_top.segurando) and jogador_top.segurando != null:
		cima = jogador_top.segurando.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR
	if is_instance_valid(jogador_bot.segurando) and jogador_bot.segurando != null:
		baixo = jogador_bot.segurando.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR
	
	if cima and baixo:
		curr_status = Status_segurando.AMBOS
	elif cima:
		curr_status = Status_segurando.CIMA
	elif baixo:
		curr_status = Status_segurando.BAIXO
	else:
		curr_status = Status_segurando.NENHUM
	
func ajeitar_locais_plantar_meio_mapa() -> void:
	update_status()
	update_mostrar()

func update_mostrar() -> void:
	match curr_status:
		Status_segurando.AMBOS:
			_mostrar_ambos()
		Status_segurando.CIMA:
			_mostrar_top()
		Status_segurando.BAIXO:
			_mostrar_bot()
		Status_segurando.NENHUM:
			locais_plantar_colecao.esconder()

func _mostrar_ambos() -> void:
	locais_plantar_colecao._mostrar()

func _mostrar_top() -> void:
	for anim in locais_plantar_colecao.animation_nodes:
		# esta na metade de baixo -> esconde
		if anim.global_position.y > divisor_meio_mapa.global_position.y:
			anim.stop()
			anim.hide()
	
func _mostrar_bot() -> void:
	for anim in locais_plantar_colecao.animation_nodes:
		# esta na metade de cima -> esconde
		if anim.global_position.y < divisor_meio_mapa.global_position.y:
			anim.stop()
			anim.hide()
