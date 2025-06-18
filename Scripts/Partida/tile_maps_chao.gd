extends Node2D
class_name TileMapsChao

@export var tilemap_agua : TileMapLayer 
@export var tilemap_lodo : TileMapLayer

# eles tem que ter a scala em x e y igual para isso funcionar
@onready var tilemap_agua_size_x = 1 / tilemap_agua.scale.x
@onready var tilemap_lodo_size_x = 1 / tilemap_lodo.scale.x

func jogador_pos_on_water(global_pos_jog : Vector2) -> bool:
	# pega o tile de agua que o jogador esta em cima
	var tile = _get_tile_data(global_pos_jog, tilemap_agua_size_x, tilemap_agua)
	
	if tile != null: # se setiver em cima de um tile existente no tilemap
		# ve se o jogador esta em cima de um tile de agua
		return tile.get_custom_data("is_water")
	return false # caso n esteja em um tile valido -> nao esta na agua

func jogador_pos_speed_lodo(global_pos_jog : Vector2) -> float:
	# pega o tile de lodo que o jogador esta em cima
	var tile = _get_tile_data(global_pos_jog, tilemap_lodo_size_x, tilemap_lodo)
	
	if tile != null: # se setiver em cima de um tile existente no tilemap
		# pega o slow_speed do tile de lodo
		return tile.get_custom_data("slow_speed")
	return 1.0 # caso n esteja em um tile valido -> nao modifica a velocidade

func _get_tile_data(global_pos_jog : Vector2, 
					tilemap_size_x : float,
					tilemap : TileMapLayer) -> TileData:
	# lida com o tilemap ter escala
	var tilemap_pos = global_pos_jog * tilemap_size_x
	# pega o tile que o jogador esta
	var tile_pos = tilemap.local_to_map(tilemap_pos)
	var tile = tilemap.get_cell_tile_data(tile_pos)
	return tile
