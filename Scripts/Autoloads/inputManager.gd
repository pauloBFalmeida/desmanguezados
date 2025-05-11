extends Node

var actions_player = {}

const action_names = [
	"move_left",
	"move_right",
	"move_down",
	"move_up"
]

func add_controller(player_id: int, device_id: int) -> void:
	actions_player[player_id] = {}
	for action_name in action_names:
		var new_name: String = action_name + "_" +str(device_id)
		var ref_name: String = "contr_" + action_name
		_clone_action(ref_name, new_name, device_id)
		actions_player[player_id][action_name] = new_name

func _clone_action(original: String, new_name: String, device_id: int):
	if not InputMap.has_action(new_name):
		InputMap.add_action(new_name)
	for event in InputMap.action_get_events(original):
		var event_copy = event.duplicate()
		event_copy.device = device_id
		InputMap.action_add_event(new_name, event_copy)
