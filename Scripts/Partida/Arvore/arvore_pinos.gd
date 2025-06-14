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
	anim_player.animation_finished.connect( _morrer )

func _morrer(_anim_name: String) -> void:
	super.morrer()

# --- mostrar atras ---
var objs_dentro_buraco : Array[Node2D] = []
func _on_area_2d_mostrar_buraco_body_entered(body: Node2D) -> void:
	objs_dentro_buraco.append(body)
	modulate.a = 0.7

func _on_area_2d_mostrar_buraco_body_exited(body: Node2D) -> void:
	if objs_dentro_buraco.has(body):
		objs_dentro_buraco.erase(body)
	if objs_dentro_buraco.is_empty():
		modulate.a = 1.0
