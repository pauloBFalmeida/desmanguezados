extends Arvore

@onready var timer_crescer := $TimerCrescer
@onready var anim_player := $AnimationPlayer
@onready var collision_area_preso := $Area2DPresoDentro/CollisionShape2D

@export var sprites_idade : Dictionary[Crescimento, Sprite2D] = {}
@export var collisions_idade : Dictionary[Crescimento, CollisionShape2D] = {}

func _ready() -> void:
	super() # chama _ready da classe Arvore
	comecar_crescer()
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
		collisions_idade[idade].disabled = false # habilita o collisor
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
	
	print(body, " dentro arvore")

func _on_area_2d_preso_dentro_body_exited(body: Node2D) -> void:
	if body_presos_dentro.has(body):
		body_presos_dentro.erase(body)
	
	print(body, " fora arvore")

func _verificar_preso_dentro(body: Node2D) -> void:
	if not body_presos_dentro.has(body): return
	# tem algo preso por mais de meio segundo
	
	# direcao que vamos empurrar o corpo
	var direcao : Vector2 = body.global_position - collision_area_preso.global_position
	direcao = direcao.normalized() * 10
	# enquanto estiver preso, empurre para fora
	while body_presos_dentro.has(body):
		#body.global_position += direcao
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(body, "global_position", body.global_position + direcao, 0.1)
		# a gente libera o processamento com esse await (o await bota o resta da funcao em "espera")
		#	para a area2D poder chamar a funcao de body_exited
		# 	que eh o que estamos verificando nesse while
		await get_tree().create_timer(0.1).timeout
		
