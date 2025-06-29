extends StaticBody2D
class_name Lixo

signal coletado

## Lista de Imagens para variar entre, se nao tiver variacoes, deixar vazio
@export var variantes_sprites : Array[CompressedTexture2D]

## Offsets das Imagens variantes, index do Vector2 no array eh referente ao da imagem no variantes_sprites
@export var variantes_offset : Array[Vector2]

## possivel de virar o sprite 90 graus que ainda faz sentido
@export var possivel_virar_90 : bool = false

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

func _ready() -> void:
	add_to_group("Lixo")
	
	# se nao foi rodado no level design, gire um pouquinho
	if is_zero_approx(rotation):
		# leve rotacao
		rotate(randf_range(-PI/12, PI/12)) # +- 15 graus
		
		# pode virar 90 graus -> 1 em 4 de acontecer
		if possivel_virar_90 and randi_range(0, 3) == 0:
			rotate(PI/2)
		# 1 em 4 de espelhar horizontalmente
		if randi_range(0, 3) == 0:
			scale.x *= -1
	
	# tem variacoes de multiplas imagens
	if variantes_sprites.size() > 1:
		# escolhe um index aleatorio da lista de imagens
		var index := randi_range(0, variantes_sprites.size()-1)
		# muda a sprite e offset para a imagem escolhida
		sprite.texture = variantes_sprites[index]
		sprite.offset = variantes_offset[index]

func recolher() -> void:
	# desativa a colisao
	collision.disabled = true
	# animacao de desaparecer
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate",
		Color.TRANSPARENT,
		0.6 # duracao
	).from_current()
	tween.finished.connect( morrer )

func morrer() -> void:
	hide()
	emit_signal("coletado")
	queue_free()
