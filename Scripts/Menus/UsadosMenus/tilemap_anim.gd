extends TileMapLayer

@export var qtd_frames : int = 4
@export var fps := 3.0

var current_frames : Dictionary[Vector2i, int]
var frame_timer := 0.0

var filled_tiles : Array

func _ready() -> void:
	filled_tiles = get_used_cells()

	for tile_pos in filled_tiles:
		var source_id = get_cell_source_id(tile_pos)
		current_frames[tile_pos] = source_id

func _physics_process(delta: float) -> void:
	frame_timer += delta

	if frame_timer >= 1.0 / fps:
		frame_timer = 0.0
		
		for tile_pos in filled_tiles:
			# atualizo o frame atual
			current_frames[tile_pos] = (current_frames[tile_pos] + 1) % qtd_frames
			var source_id = current_frames[tile_pos]
			# proximo frame de animacao
			set_cell(
				tile_pos,
				source_id,
				Vector2i(0,0),
				0
			)
