extends Sprite2D

var device_id : int = -1

var speed: float = 250.0

var action : Dictionary

func _process(delta: float) -> void:
	var move_dir = Input.get_vector(action["move_left"], action["move_right"], action["move_up"], action["move_down"])
	
	global_position += move_dir * delta * speed

func _input(event):
	## do nothing if device id does not match the assigned id
	if event.device != device_id:
		return

	## do nothing if no device id assigned
	if device_id == -1:
		return
	
	## Process events!
	if (Input.is_action_just_pressed("x")):
		visible = not visible
