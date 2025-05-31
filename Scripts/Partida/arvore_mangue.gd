extends Arvore

@onready var timer_crescer := $TimerCrescer

@export var sprites_idade : Dictionary[Crescimento, Sprite2D] = {}

func _ready() -> void:
	comecar_crescer()

func comecar_crescer() -> void:
	super.comecar_crescer()
	# inicia o timer para esperar "crescimento_time" para crescer
	timer_crescer.start(crescimento_time)

func crescer() -> void:
	sprites_idade[idade].hide()
	super.crescer()
	sprites_idade[idade].show()

	if idade == Crescimento.ADULTA:
		timer_crescer.stop()


func _on_timer_crescer_timeout() -> void:
	crescer()
