extends Node2D

var capivaras : Array[AnimatedSprite2D]

@export var capivara_tempo_mov := 6.0

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			var capivara_id = capivaras.size()
			var tempo = _calc_tempo()
			capivaras.append(child)
			get_tree().create_timer(tempo).timeout.connect( _mover.bind(capivara_id) )
			

func _calc_tempo() -> float:
	# +-20% de adicional de tempo capivara_tempo_mov 
	return (1 + randf_range(-0.2, 0.2)) * capivara_tempo_mov

func _calc_new_pos(global_pos : Vector2) -> Vector2:
	var offset = Vector2(randi_range(30, 40), 0).rotated(randf_range(-PI, PI))
	var new_pos = global_pos + offset
	# ve se caiu fora da tela -> se cair vai pro lado oposto
	var screen_size = get_viewport().get_visible_rect().size
	if new_pos.x > screen_size.x:
		new_pos = global_pos - offset
	elif new_pos.y > screen_size.y:
		new_pos = global_pos - offset
	elif new_pos.x < 0:
		new_pos = global_pos - offset
	elif new_pos.y < 0:
		new_pos = global_pos - offset

	return new_pos

func _mover(capivara_id : int) -> void:
	var tempo = _calc_tempo()
	match randi_range(0, 1):
		0: # fica parada
			pass
		1: # move
			var new_pos = _calc_new_pos(capivaras[capivara_id].global_position)
			# indo para direita
			if new_pos.x > capivaras[capivara_id].global_position.x:
				capivaras[capivara_id].flip_h = false
			else: # indo para esquerda
				capivaras[capivara_id].flip_h = true
			var tween := create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(
				capivaras[capivara_id],
				'global_position',
				new_pos,
				tempo,
			).from_current()
	# chama de novo
	get_tree().create_timer(tempo).timeout.connect( _mover.bind(capivara_id) )
	
