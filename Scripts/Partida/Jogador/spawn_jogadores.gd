extends Node2D
class_name SpawnJogadores

@export var ferramentas_mgmt : FerramentaMgmt
@export var tilemap_lodo : TileMapDual

var jogadores : Array[Jogador]

@onready var tilemap_lodo_size_x = 1 / tilemap_lodo.scale.x

func _ready() -> void:
	for jogador : Jogador in get_children():
		jogadores.append(jogador)

func _physics_process(delta: float) -> void:
	# ---- slow down do terreno ----
	for jogador in jogadores:
		# pega o slow_speed do tilemap lodo
		var tilemap_pos = jogador.global_position * tilemap_lodo_size_x
		var tile_pos = tilemap_lodo.local_to_map(tilemap_pos)
		var tile = tilemap_lodo.get_cell_tile_data(tile_pos)
		
		var speed_modifier : float
		if tile != null: # se setiver em cima de um tile existente no tilemap
			speed_modifier = tile.get_custom_data("slow_speed")
		else:
			speed_modifier = 1.0
		# coloca no jogador o speed modifier
		jogador.set_speed_modifier_terreno(speed_modifier)

func get_ferramentas_mgmt() -> FerramentaMgmt:
	return ferramentas_mgmt
