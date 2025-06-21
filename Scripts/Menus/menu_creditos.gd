extends Menu

@export var spawn_jogadores : SpawnJogadores
@export var ferramentas_mgmt : FerramentaMgmt
@export var locais_plantar_colecao : LocalPlantarColecao

const local_plantar_ref := preload("res://Cenas/Partida/local_plantar.tscn")
const texto_creditos_ref := preload("res://Cenas/Menus/SubItems/texto_creditos.tscn")

@onready var textos_creditos_pai := $Textos

var local_plantar_pos_to_corpo : Dictionary[Vector2, String] = {}

func _ready() -> void:
	_ajustar_plantar()
	# ajusta cada ferramenta para ter um efeito
	for ferramenta in ferramentas_mgmt.ferramentas_level:
		match ferramenta.tipo_ferramenta:
			Ferramenta.Ferramenta_tipo.CORTAR:
				ferramenta.usou.connect(usar_cortar.bind(ferramenta))
			Ferramenta.Ferramenta_tipo.RECOLHER:
				ferramenta.usou.connect(usar_recolher.bind(ferramenta))
			Ferramenta.Ferramenta_tipo.PLANTAR:
				# _ajustar_plantar faz essa parte
				pass
	
	for corpo : TextoCreditos in textos_creditos_pai.get_children():
		corpo.hit.connect(_chamar_spawn_plantar.bind(corpo))

func _chamar_spawn_plantar(corpo : TextoCreditos) -> void:
	var global_pos := corpo.start_global_pos
	_spawn_plantar(global_pos)
	local_plantar_pos_to_corpo[global_pos] = corpo.get_texto()

func _ajustar_plantar() -> void:
	ferramentas_mgmt.set_locais_plantar_colecao(locais_plantar_colecao)
	
	# remove a funcao de plantar padrao
	#	qnd usa a ferramenta de plantar, ela pede pro locais de plantar plantar_muda
	#	assim locais de plantar colecao envia um signal 'plantar' 
	#	que ferramenta_mgmt capta e usa para plantar a arvore
	#	assim a gente remove essa parte de plantar a muda
	#	e pode usar a funcao que a gente quiser pra qnd o jogador usar "plantar"
	var conexoes = locais_plantar_colecao.plantar.get_connections()
	for conexao in conexoes:
		var _callable = conexao['callable']
		locais_plantar_colecao.plantar.disconnect(_callable)
	# nova funcao plantar
	locais_plantar_colecao.plantar.connect(usar_plantar)

var cortar_force := 1200.0

func usar_cortar(body : Node2D, ferramenta : Ferramenta) -> void:
	var corpo : RigidBody2D = body
	
	var global_pos := corpo.global_position
	var jogador : Jogador = ferramenta.get_parent()
	var direcao := jogador.to_local(global_pos)
	direcao = direcao.normalized()
	
	corpo.receber_hit(direcao, cortar_force)

func usar_recolher(body : Node2D, ferramenta : Ferramenta) -> void:
	var corpo : TextoCreditos = body
	# fade out
	corpo.toggle_collision(false)
	var tween = create_tween()
	tween.tween_property(
		corpo.get_label(),
		"modulate:a",
		0.0,
		0.5 # duracao
	).from_current()
	tween.finished.connect(
		func():
			if not corpo.was_hit: # se nao levou dano
				# spawna lugar para ser plantado
				await _chamar_spawn_plantar(corpo)
			# libera memoria
			corpo.queue_free()
	)

func usar_plantar(global_pos : Vector2) -> void:
	var texto := local_plantar_pos_to_corpo[global_pos]
	
	# remove da lista de locais para plantar
	local_plantar_pos_to_corpo.erase(global_pos)
	# spawn texto creditos
	_spawn_texto_credito(texto, global_pos)
	
	# fake wait, para ter certeza que fez essa func antes de free o texto_creditos antigo
	await get_tree().create_timer(0.1).timeout

func _spawn_texto_credito(texto : String, global_pos : Vector2) -> void:
	var tween = create_tween()
	var texto_creditos = texto_creditos_ref.instantiate()
	texto_creditos.global_position = global_pos # isso tem que ser feito antes do _ready
	textos_creditos_pai.add_child(texto_creditos)
	
	texto_creditos.hit.connect(_chamar_spawn_plantar.bind(texto_creditos))
	texto_creditos.set_texto(texto)
	# fade in
	texto_creditos.toggle_collision(false)
	texto_creditos.get_label().modulate.a = 0.0
	tween.tween_property(
		texto_creditos.get_label(),
		"modulate:a",
		1.0,
		1.5 # duracao
	).from_current()
	tween.finished.connect(func(): texto_creditos.toggle_collision(true))

func _spawn_plantar(global_pos : Vector2) -> void:
	# -- cria o local de plantar ---
	var local_plantar = local_plantar_ref.instantiate()
	# pega o marcador verde de local de plantar
	var marca : Sprite2D = local_plantar.get_node("Icon") 
	marca.hide()
	# add to colecao
	local_plantar.global_position = global_pos
	locais_plantar_colecao.add_local_plantar(local_plantar)

# ------------------------------------------------------------------------------
# Voltar para o menu
# ------------------------------------------------------------------------------
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

# override para n sair do menu com voltar do controle
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		voltar_menu_principal()

var dentro_area_voltar : Array[Jogador] = []
func _on_area_2d_voltar_body_entered(body: Node2D) -> void:
	dentro_area_voltar.append(body)
	get_tree().create_timer(1.5).timeout.connect(_passou_tempo.bind(body))

func _on_area_2d_voltar_body_exited(body: Node2D) -> void:
	if dentro_area_voltar.has(body):
		dentro_area_voltar.erase(body)

func _passou_tempo(jogador : Jogador) -> void:
	if dentro_area_voltar.has(jogador):
		voltar_menu_principal()
