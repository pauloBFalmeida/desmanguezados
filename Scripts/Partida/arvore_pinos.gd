extends Arvore

@onready var anim_player := $AnimationPlayer

func _ready() -> void:
	super() # chama _ready da classe Arvore
	idade = Crescimento.ADULTA

func cortar() -> void:
	# nao faz nada se tiver sendo cortada
	if not viva: return
	viva = false
	
	anim_player.play("cortar")
	anim_player.animation_finished.connect( morrer )

func morrer(_anim_name: String) -> void:
	hide()
	# TODO: signal
	queue_free()
