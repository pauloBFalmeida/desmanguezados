extends Sprite2D
class_name ThrowSpriteChao

@export var sprite_valido : CompressedTexture2D
@export var sprite_invalido : CompressedTexture2D

var fora_tela : bool = false

func mostrar_valido() -> void:
	texture = sprite_valido

func mostrar_invalido() -> void:
	texture = sprite_invalido

func esconder() -> void:
	hide()

func mostrar() -> void:
	show()

func is_fora_tela() -> bool:
	return fora_tela

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	fora_tela = true

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	fora_tela = false
