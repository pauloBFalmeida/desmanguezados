extends Level

@export var duracao_mare_subir_block    : float = 3.0
@export var duracao_mare_cheia          : float = 3.0
@export var duracao_mare_descer_block   : float = 3.0
@export var duracao_mare_descer_andavel : float = 4.0
@export var duracao_mare_vazia          : float = 4.0
@export var duracao_mare_subir_andavel  : float = 4.0
@export var tile_mare : TileMapLayer

@export var mare_andavel_min_color : Color
@onready var mare_cheia_color : Color = tile_mare.modulate

@onready var timer_mare := $TimerMare
@onready var area_2d_mare := $Area2DMare

enum Mare {CHEIA, DESCENDO_BLOCK, DESCENDO_ANDAVEL, VAZIA, SUBINDO_ANDAVEL, SUBINDO_BLOCK}
var mare_atual : Mare = Mare.CHEIA

func _ready() -> void:
	super()
	timer_mare.start(duracao_mare_cheia)


func _on_timer_agua_timeout() -> void:
	# fim da mare atual -> comecar a proxima fase da mare
	match mare_atual:
		Mare.CHEIA:
			_mare_descendo_block()
		Mare.DESCENDO_BLOCK:
			_mare_descendo_andavel()
		Mare.DESCENDO_ANDAVEL:
			_mare_vazia()
		Mare.VAZIA:
			_mare_subindo_andavel()
		Mare.SUBINDO_ANDAVEL:
			_mare_subindo_block()
		Mare.SUBINDO_BLOCK:
			_mare_cheia()

func _mare_cheia() -> void:
	mare_atual = Mare.CHEIA
	timer_mare.start(duracao_mare_cheia)

func _mare_descendo_block() -> void:
	mare_atual = Mare.DESCENDO_BLOCK
	timer_mare.start(duracao_mare_descer_block)
	# animacao -> ficar atravessavel
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		tile_mare, "modulate",
		mare_andavel_min_color,
		duracao_mare_descer_block
	).from_current()
	
func _mare_descendo_andavel() -> void:
	mare_atual = Mare.DESCENDO_ANDAVEL
	timer_mare.start(duracao_mare_descer_andavel)
	# desabilita a colisao
	tile_mare.collision_enabled = false
	area_2d_mare.monitoring = false
	
	# animacao -> ficar inivisivel
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		tile_mare, "modulate:a",
		0.0,
		duracao_mare_descer_andavel
	).from_current()

func _mare_vazia() -> void:
	mare_atual = Mare.VAZIA
	timer_mare.start(duracao_mare_vazia)

func _mare_subindo_andavel() -> void:
	mare_atual = Mare.SUBINDO_ANDAVEL
	timer_mare.start(duracao_mare_subir_andavel)
	
	# animacao -> ficar block
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		tile_mare, "modulate",
		mare_andavel_min_color,
		duracao_mare_subir_andavel
	).from_current()
	
func _mare_subindo_block() -> void:
	mare_atual = Mare.SUBINDO_BLOCK
	timer_mare.start(duracao_mare_subir_block)
	# colocar colisao
	tile_mare.collision_enabled = true
	area_2d_mare.monitoring = true
	
	# animacao -> ficar cheia
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		tile_mare, "modulate",
		mare_cheia_color,
		duracao_mare_subir_block
	).from_current()

# ---- preso na mare ----
var bodys_dentro_mare : Array[Node2D]
func _on_area_2d_mare_body_entered(body: Node2D) -> void:
	bodys_dentro_mare.append(body)
	get_tree().create_timer(0.5).timeout.connect(_verificar_preso_mare.bind(body))

func _on_area_2d_mare_body_exited(body: Node2D) -> void:
	if bodys_dentro_mare.has(body):
		bodys_dentro_mare.erase(body)

func _verificar_preso_mare(body: Node2D) -> void:
	# ficou preso por tempo suficiente -> empurra em X pra fora
	if bodys_dentro_mare.has(body):
		var direcao : Vector2 = area_2d_mare.to_local(body.global_position)
		direcao.y = 0
		direcao = direcao.normalized() * 15
		# enquanto tiver, empurre pra fora
		while bodys_dentro_mare.has(body):
			#body.global_position += direcao
			var tween := create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(body, "global_position", body.global_position + direcao, 0.25)
			# espera liberando o processamento
			await tween.finished
