extends Arvore

@onready var timer_crescer := $TimerCrescer
@onready var anim_player := $AnimationPlayer

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
	if not mostrar:
		sprites_idade[idade].hide()
		collisions_idade[idade].hide()
		collisions_idade[idade].disabled = true
	else:
		sprites_idade[idade].show()
		collisions_idade[idade].show()
		collisions_idade[idade].disabled = false
		

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


func _on_area_2d_preso_dentro_body_exited(body: Node2D) -> void:
	print("jogador saiu arvore")

func _on_area_2d_preso_dentro_body_entered(body: Node2D) -> void:
	print("jogador dentro arvore")
