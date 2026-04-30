extends AnimatedSprite2D
class_name JogadorAnimation

enum Skin_tipo {CORTAR, PLANTAR, PLANTAR_HATLESS, RECOLHER, NORMAL}
enum Movimento_tipo {ACAO, ANDAR, PARADO, NULL}

@export var anim_blue : Dictionary[Skin_tipo, SpriteFrames]
@export var anim_red  : Dictionary[Skin_tipo, SpriteFrames]

var cor : Jogador.Jogador_cor_id

@export var curr_mov : Movimento_tipo = Movimento_tipo.NULL :
	set(mov):
		curr_mov = mov
		_update_animacao()

var prev_mov_duracao_ms : int = 0
var prev_mov_start_ms : int = 0

@export var curr_skin : Skin_tipo = Skin_tipo.NORMAL :
	set(skin):
		curr_skin = skin
		_display_mudar_skin(skin)

func set_cor(_cor : Jogador.Jogador_cor_id) -> void:
	cor = _cor

func mudar_skin(skin : Skin_tipo) -> void:
	curr_skin = skin
	_display_mudar_skin(skin)

func _display_mudar_skin(skin : Skin_tipo) -> void:
	# se a cor do jogador seja azul -> pega do dict azul
	if cor == Jogador.Jogador_cor_id.BLUE:
		sprite_frames = anim_blue[skin]
	else: # cor vermelha -> pega do dict red
		sprite_frames = anim_red[skin]
	# atualiza o movimento
	set_movimento(curr_mov)

# duracao em seg
func mudar_movimento(mov : Movimento_tipo, duracao : float = 0.2) -> void:
	# se ja estiver fazendo esse movimento -> nao comece de novo
	if mov == curr_mov: return
	# -- comecando mov novo --
	
	var current_time = Time.get_ticks_msec()  # milisec da godot
	
	# acao tem preferencia sobre todos os outros tipos de movimentos
	# 		ou seja, se nao for acao, veja se o mov anterior ja acabou
	if mov != Movimento_tipo.ACAO:
	
		# nao passou mais tempo do que o comeco + duracao do mov anterior,
		# 		ou seja, nao acabou o prev, -> mt cedo, continue o prev
		if current_time < prev_mov_start_ms + prev_mov_duracao_ms:
			return
	
	# -- mudar para novo mov --
	prev_mov_start_ms = current_time
	prev_mov_duracao_ms = int(duracao * 1000) # converte seg -> miliseg
	set_movimento(mov)

func set_movimento(mov : Movimento_tipo) -> void:
	# salva o movimento atual
	curr_mov = mov

func _update_animacao() -> void:
	match curr_mov:
		Movimento_tipo.ACAO:
			play("acao")
		Movimento_tipo.ANDAR:
			play("andar")
		Movimento_tipo.PARADO:
			play("parado")
