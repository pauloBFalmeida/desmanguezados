extends Control

@onready var buttonStart := $ButtonStart
@onready var image := $TextureRect

var level_id : SceneManager.Level_id

func btn_grab_focus() -> void:
	buttonStart.grab_focus()

func ajust(_level_id : int) -> void:
	level_id = _level_id
	# texto
	var texto_btn : String = "Sem_Nome" 
	if SceneManager.LEVEIS_NOME.has(level_id):
		texto_btn = SceneManager.LEVEIS_NOME[level_id]
	buttonStart.text = texto_btn
	# imagem
	if SceneManager.LEVEIS_IMAGE.has(level_id):
		image.texture = SceneManager.LEVEIS_IMAGE[level_id]
	

func _on_button_start_pressed() -> void:
	SceneManager.goto_level(level_id)
