extends Arvore

@onready var timer_crescer := $TimerCrescer
@onready var anim_player := $scaled/AnimationPlayer
@onready var collision_area_preso := $Area2DPresoDentro/CollisionShape2D

@export var sprites_idade : Dictionary[Crescimento, Sprite2D] = {}
@export var collisions_idade : Dictionary[Crescimento, CollisionShape2D] = {}

@onready var front_z_index := z_index
@onready var behind_z_index := 0

func _ready() -> void:
	super() # chama _ready da classe Arvore
	#comecar_crescer()
	# desligar as colisoes e sprites
	for key in sprites_idade.keys():
		sprites_idade[key].hide()
		collisions_idade[key].hide()
		collisions_idade[key].disabled = true
	# ligar as colisoes e sprites atuais
	_update_sprite(true)

func comecar_crescer() -> void:
	super.comecar_crescer()
	# inicia o timer para esperar "crescimento_time" para crescer
	timer_crescer.start(crescimento_time)

func crescer() -> void:
	_update_sprite(false) # esconde a sprite antiga (antes de atualizar a idade)
	super.crescer()
	_update_sprite(true) # mostra a sprite nova (dps de atualizar a idade)

	if idade == Crescimento.ADULTA:
		timer_crescer.stop()

## mostrar == true -> aparece a sprite, mostrar == false -> esconde 
func _update_sprite(mostrar : bool) -> void:
	if mostrar: # mostrar
		sprites_idade[idade].show()
		collisions_idade[idade].show()
		# se for arvore bebe -> desabilita a colisao
		if idade == Crescimento.BEBE:
			collisions_idade[idade].disabled = true
			front_z_index = 0
			_update_buraco()
		else:
			collisions_idade[idade].disabled = false # habilita o collisor
			front_z_index = 10
			_update_buraco()
		# update area2D stuck inside
		collision_area_preso.shape = collisions_idade[idade].shape
		collision_area_preso.transform = collisions_idade[idade].transform
		
	else: # esconder
		sprites_idade[idade].hide()
		collisions_idade[idade].hide()
		collisions_idade[idade].disabled = true # desabilita o collisor
		

func _on_timer_crescer_timeout() -> void:
	crescer()

func cortar() -> void:
	# nao faz nada se tiver sendo cortada
	if not viva: return
	viva = false
	
	anim_player.play("cortar")
	anim_player.animation_finished.connect( _morrer )

func _morrer(_anim_name: String) -> void:
	super.morrer()

# ---- Stuck -> algo preso dentro ---
var body_presos_dentro : Dictionary[Node2D, Node2D]
func _on_area_2d_preso_dentro_body_entered(body: Node2D) -> void:
	body_presos_dentro[body] = body
	get_tree().create_timer(0.5).timeout.connect(_verificar_preso_dentro.bind(body))

func _on_area_2d_preso_dentro_body_exited(body: Node2D) -> void:
	if body_presos_dentro.has(body):
		body_presos_dentro.erase(body)

func _verificar_preso_dentro(body: Node2D) -> void:
	if not body_presos_dentro.has(body): return
	# tem algo preso por mais de meio segundo
	
	# direcao que vamos empurrar o corpo
	var direcao : Vector2 = body.global_position - collision_area_preso.global_position
	direcao = direcao.normalized() * 13
	
	# quantide de tentativas
	const tentativas_max := 4
	var tentativas : int = 0
	var rodar_rad : float = 0.61 * PI # roda em +- 110 graus 
	# enquanto estiver preso, empurre para fora
	while body_presos_dentro.has(body):
		var posicao = body.global_position + direcao
		
		tentativas += 1
		if tentativas > tentativas_max:
			tentativas = 0
			# roda pro outro lado
			direcao = direcao.rotated(rodar_rad)
			# vai em outro sentido da arvore
			posicao = global_position + direcao
		
		# smooth
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(body, "global_position", posicao, 0.2)
		# libera o processamento do programa com esse await (o await bota o resto da funcao em "espera" -> yield)
		#	para a area2D poder chamar a funcao de body_exited
		# 	que eh o que estamos verificando nesse while
		await tween.finished


# --- mostrar atras ---
var objs_dentro_buraco : Array[Node2D] = []
func _on_area_2d_mostrar_buraco_body_entered(body: Node2D) -> void:
	objs_dentro_buraco.append(body)
	_update_buraco()

func _on_area_2d_mostrar_buraco_body_exited(body: Node2D) -> void:
	if objs_dentro_buraco.has(body):
		objs_dentro_buraco.erase(body)
	_update_buraco()

func _update_buraco() -> void:
	if objs_dentro_buraco.is_empty():
			z_index = behind_z_index
			modulate.a = 1.0
	else:
		z_index = front_z_index
		modulate.a = 0.7
