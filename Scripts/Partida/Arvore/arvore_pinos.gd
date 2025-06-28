extends Arvore

@onready var anim_player := $AnimationPlayer
@onready var particulas := $GPUParticles2D

@onready var front_z_index := z_index
@onready var behind_z_index := 0


func _ready() -> void:
	super() # chama _ready da classe Arvore
	idade = Crescimento.ADULTA

func cortar(jog : Jogador) -> void:
	# nao faz nada se tiver sendo cortada
	if not viva: return
	viva = false
	
	# mostra as particular
	mostrar_particulas(jog)
	
	anim_player.play("cortar")
	anim_player.animation_finished.connect( _morrer )

func mostrar_particulas(jog : Jogador) -> void:
	# direcao do jogador para as particulas
	var dir := jog.position.angle_to(jog.to_local(particulas.global_position))
	particulas.rotation = dir
	print(dir)
	
	particulas.global_position.y = jog.global_position.y + 20
	particulas.emitting = true

func _morrer(_anim_name: String) -> void:
	super.morrer()

# --- mostrar atras ---
var objs_dentro_buraco : Array[Node2D] = []
func _on_area_2d_mostrar_buraco_body_entered(body: Node2D) -> void:
	objs_dentro_buraco.append(body)
	modulate.a = 0.7
	z_index = front_z_index

func _on_area_2d_mostrar_buraco_body_exited(body: Node2D) -> void:
	if objs_dentro_buraco.has(body):
		objs_dentro_buraco.erase(body)
	if objs_dentro_buraco.is_empty():
		modulate.a = 1.0
		z_index = behind_z_index
