extends Control

@onready var buttonStart := $ButtonStart

var level_num : int

func btn_grab_focus() -> void:
	buttonStart.grab_focus()

func ajust(_level_num : int) -> void:
	level_num = _level_num
	#buttonStart.pressed.connect( func(): 
	#)
	# texto
	buttonStart.text = "Level " + str(level_num)

func _on_button_start_pressed() -> void:
	SceneManager.goto_level(level_num)
