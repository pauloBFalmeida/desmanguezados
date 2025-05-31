extends Arvore

@onready var timer_crescer := $TimerCrescer

@export var sprites_idade : Dictionary[Crescimento, Sprite2D] = {}
@export var collisions_idade : Dictionary[Crescimento, CollisionShape2D] = {}

func _ready() -> void:
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
