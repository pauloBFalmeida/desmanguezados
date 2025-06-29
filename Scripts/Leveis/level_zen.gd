extends Level

func _ready() -> void:
	super()
	temporizador.parar() # para de contar o tempo
	# gera o mapa aleatoriamente
	gerar_mapa_aleatorio()
	ajustar_objetivos() # re ajusta as arvores e tals
	# lidar com a quantidade de jogadores
	lidar_qtd_jogadores_zen()
	# camera zoom
	camera_zoom_in()

# --------------------------------------------- Qtd de jogadores
@onready var jogadores := $SpawnJogadores.get_children()

func lidar_qtd_jogadores_zen() -> void:
	if Globais.modo_zen_ter_1_jogador:
		for jog in jogadores:
			if jog != camera_target:
				jog.global_position = Vector2(-999, -999)
				jog.hide()
				jog.set_physics_process(false)
				jog.set_process(false)
				jog.set_process_input(false)

# --------------------------------------------- Camera seguir jogador
@export var max_distance_target : float = 50.0
@export var camera_lerp_speed_curve: Curve
@export var camera_lerp_speed: float = 3.0
@export var camera_target : Node2D
@onready var camera := $Camera2D

@onready var screen_center : Vector2 = camera.global_position
@onready var screen_center_length : float = screen_center.length()

var position_target : Vector2 = Vector2.ZERO
var dist_out_cam : float = 0.0

func _process(delta: float) -> void:
	var direcao : Vector2 = camera_target.global_position - camera.global_position
	if direcao.length() > max_distance_target:
		var dist = direcao.length() / screen_center_length
		var weight : float = camera_lerp_speed_curve.sample(dist) * camera_lerp_speed
		camera.global_position = lerp(camera.global_position,
									camera_target.global_position, 
									weight * delta)

func camera_zoom_in() -> void:
	# afasta a camera
	camera.zoom = Vector2.ONE * 0.4
	# esconde a hud (pq esta menor q a tela)
	hud.hide()
	# esconde arvores e lixo
	var itens_list = arvores_colecao.get_children() + lixos_colecao.get_children()
	for item in itens_list:
		item.hide()
	
	# espera a cinematica
	var duracao : float = 2.0
	await show_cinematic(duracao, itens_list)
	
	# zoom in
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		camera,
		"zoom",
		Vector2.ONE,
		2.5 			# duracao
	).from_current()
	
	# espera o zoom chegar perto do fim para mostrar a hud e comecar a contar
	await get_tree().create_timer(1.5, true).timeout
	hud.show()
	hud.comecar_contar()

func show_cinematic(duracao: float, itens_list : Array) -> bool:
	var tempo_item = duracao / itens_list.size()
	
	for item in itens_list:
		item.show()
		await get_tree().create_timer(tempo_item, true).timeout
	
	return true # para funcionar o await

# --------------------------------------------- Gerar Mapa Aleatorio
@export var map_size : Vector2i = Vector2i(50, 50)
@export var noise_scale_ilha : float = 0.05
@export var noise_scale_terreno : float = 0.1
@export var island_radius : float = 1.0  # Controls the strength of falloff
@export var land_threshold : float = 0.2
@export var terreno_threshold_raizes : float = 0.1
@export var terreno_threshold_lodo : float = 0.4

@onready var tilemap_areia := $TileMaps/TileMapDualAreia
@onready var tilemap_raizes := $TileMaps/TileMapDualRaizes
@onready var tilemap_lodo := $TileMaps/TileMapDualLodo
@onready var tilemap_agua := $TileMaps/TileMapLayerAgua

@export var tile_size : float = 15.0 * 3

const pinos_ref := preload("res://Cenas/Partida/Arvores/arvore_pinos.tscn")
const mangue_ref := preload("res://Cenas/Partida/Arvores/arvore_mangue.tscn")
const lixos_ref := [
	preload("res://Cenas/Partida/Lixos/lixo_embalagem.tscn"),
	preload("res://Cenas/Partida/Lixos/lixo_garrafa.tscn"),
	preload("res://Cenas/Partida/Lixos/lixo_lata.tscn"),
	preload("res://Cenas/Partida/Lixos/lixo_saco.tscn"),
]

## matrix[y][x] de bool, que marca o que eh chao no mapa inteiro
var is_land_map : Array[Array] = []
## lista de Vector2i de coordenas do chao jogavel do mapa
var coords_jogavel : Array = []
## martix[y][x] de bool, que marca o que eh a parte jogavel do mapa
var is_jogavel_coods : Array[Array] = []

var noise := FastNoiseLite.new()

func gerar_mapa_aleatorio() -> void:
	noise.seed = Globais.modo_zen_mapa_seed
	noise.frequency = noise_scale_ilha
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	_criar_matriz_bool(is_jogavel_coods)
	_criar_matriz_bool(is_land_map)
	# crio o que vai ser o mapa do chao
	#		pode criar outras ilhas e pedacinhos em volta
	generate_island_chao(is_land_map)
	# pego so a maior regiao unida do mapa -> como area jogavel
	coords_jogavel = find_largest_region(is_land_map)
	for coord in coords_jogavel:
		is_jogavel_coods[coord.y][coord.x] = true
	# gera os terrenos de raizes e lodo por cima do chao do mapa inteiro
	gerar_terrenos(tilemap_raizes, tilemap_lodo, terreno_threshold_raizes, -terreno_threshold_lodo)
	# gerar agua em volta
	gerar_agua(is_jogavel_coods) # is jogavel, prevenir jogar ferramentas nos ilhotas
	
	# === Spawn - posiciona o jogador e ferramentas ===
	var tamanho_spawn = 4
	var centro_spawn = encontrar_bloco(tamanho_spawn) # acha um bloco de tamanho_spawn x tamanho_spawn
	gerar_spawn(centro_spawn, tamanho_spawn)
	
	# === gera o lixo e as arvores ===
	gerar_objetivos(coords_jogavel, is_jogavel_coods)

func gerar_objetivos(coords_jogavel : Array, is_jogavel_coods : Array) -> void:
	var tamanho_mapa = coords_jogavel.size()
	# pinos + mangue nao podem maior que 1/9 = 0.11 (pq cada spawn tira 3x3 de coords)
	var qtd_pinos : int = tamanho_mapa * 0.07 
	var qtd_mangue : int = tamanho_mapa * 0.01
	# lixo nao podem maior que 1/9 = 0.11 (pq cada spawn tira 3x3 de coords)
	var qtd_lixo : int = tamanho_mapa * 0.09
	
	# ajusta as listas de coordenadas de spawn
	var coords_arvores = coords_jogavel.duplicate(true)
	var coords_lixo = coords_jogavel.duplicate(true)
	coords_arvores.shuffle()
	coords_lixo.shuffle()
	
	# Spawn Arvores Pinos
	while (qtd_pinos > 0):
		var pinos = pinos_ref.instantiate()
		var pos = _calc_coord_remover_redor(coords_arvores, coords_lixo)
		pinos.global_position = pos
		arvores_colecao.add_child(pinos)
		# conta que add uma arvore
		qtd_pinos -= 1
	
	# Spawn Arvores Mangue
	while (qtd_mangue > 0):
		var mangue : Arvore = mangue_ref.instantiate()
		var pos = _calc_coord_remover_redor(coords_arvores, coords_lixo)
		mangue.global_position = pos
		mangue.idade = Arvore.Crescimento.JOVEM # spawn meia idade
		arvores_colecao.add_child(mangue)
		# conta que add uma arvore
		qtd_mangue -= 1
	
	# Spawn Lixo
	while (qtd_lixo > 0):
		var lixo = lixos_ref.pick_random().instantiate()
		var pos = _calc_coord_remover_redor(coords_lixo)
		lixo.global_position = pos
		lixos_colecao.add_child(lixo)
		# conta que add um lixo ao mapa
		qtd_lixo -= 1


func _calc_coord_remover_redor(coords_list : Array, coords_lixo_ : Array = []) -> Vector2i:
	var coord = coords_list.pop_front()
	# verifica os offset
	var x = coord.x
	var y = coord.y
	var cantos = [0, 0, 0, 0] # cima, esq, baixo, dir
	if is_jogavel_coods[y-1][x]:
		cantos[0] = -tile_size/2
	if is_jogavel_coods[y][x-1]:
		cantos[1] = -tile_size/2
	if is_jogavel_coods[y+1][x]:
		cantos[2] =  tile_size/2
	if is_jogavel_coods[y][x+1]:
		cantos[3] =  tile_size/2
	# calcula a pos global
	var pos = _coord_to_global_pos(coord)
	#	adiciona os offsets
	var x_off = randf_range(cantos[1], cantos[3])
	var y_off = randf_range(cantos[0], cantos[2])
	# ajeita a posicao 
	pos = pos + Vector2(x_off, y_off)
	# impede de crescer arvore dos lados
	for y_ in range(-1, 2):
		for x_ in range(-1, 2):
			coords_list.erase( Vector2i(x + x_, y + y_) )
	# impede o lixo de spawnar no exato msm da arvore
	coords_lixo_.erase( Vector2i(x, y) )
	# retorna
	return pos


func gerar_spawn(centro_coord : Vector2i, tamanho_spawn : int) -> void:
	# posiciona os jogadores
	var pos_jog1 = _coord_to_global_pos(Vector2i(centro_coord.x-1, centro_coord.y-1))
	var pos_jog2 = _coord_to_global_pos(Vector2i(centro_coord.x+1, centro_coord.y+1))
	jogadores[0].global_position = pos_jog1
	jogadores[1].global_position = pos_jog2
	
	# ferramentas
	var pos_fer = [
		_coord_to_global_pos(Vector2i(centro_coord.x-3, centro_coord.y-3)),
		_coord_to_global_pos(Vector2i(centro_coord.x+3, centro_coord.y-3)),
		_coord_to_global_pos(Vector2i(centro_coord.x,   centro_coord.y-4))
	]
	for ferram in ferramenta_mgmt.ferramentas_level:
		ferram.global_position = pos_fer.pop_front()
	
	# remove o spawn da area jogavel -> para impedir spawnar coisas dentro
	for y_off in range(-tamanho_spawn, tamanho_spawn+1):
		var y = centro_coord.y + y_off
		for x_off in range(-tamanho_spawn, tamanho_spawn+1):
			var x = centro_coord.x + x_off
			is_jogavel_coods[y][x] = false
			coords_jogavel.erase(Vector2i(x,y))

## retorna o centro do bloco
func encontrar_bloco(tam : int) -> Vector2i:
	var coord : Vector2i
	var buscando := true
	while buscando:
		coord = coords_jogavel.pick_random()
		var x = coord.x
		var y = coord.y
		if x > tam and y > tam and x < map_size.x-tam and y < map_size.y-tam:
			var tem_bloco = true
			for y_off in range(-tam, tam+1):
				for x_off in range(-tam, tam+1):
					# nao tem a posicao
					if not is_jogavel_coods[y + y_off][x + x_off]:
						tem_bloco = false
						break
			if tem_bloco:
				buscando = false
	return coord

func gerar_agua(isnt_water_matrix : Array) -> void:
	for y in map_size.y:
		for x in map_size.x:
			if not isnt_water_matrix[y][x]:
				tilemap_agua.set_cell(Vector2i(x,y) , 0, Vector2i(0,0), 0)
	var coords : Vector2i
	# lateral verticalmente
	for y in range(-20, map_size.y + 21):
		for x in range(1, 21):
			# esquerda do mapa
			coords = Vector2i(-x, y)
			tilemap_agua.set_cell(coords, 0, Vector2i(3,3), 0)
			# direita do mapa
			coords = Vector2i(map_size.x + x -1, y)
			tilemap_agua.set_cell(coords, 0, Vector2i(3,3), 0)
	# horizontalmente
	for y in range(1, 21):
		for x in range(0, map_size.x):
			# em cima do mapa
			coords = Vector2i(x, -y)
			tilemap_agua.set_cell(coords, 0, Vector2i(3,3), 0)
			# embaixo do mapa
			coords = Vector2i(x, map_size.y + y -1)
			tilemap_agua.set_cell(coords, 0, Vector2i(3,3), 0)

func gerar_terrenos(tilemap_1 : TileMapDual, tilemap_2 : TileMapDual,
				threshold_terreno_1 : float = 0.2, threshold_terreno_2 : float = -0.2) -> void:
	noise.frequency = noise_scale_terreno
	for y in map_size.y:
		for x in map_size.x:
			if is_land_map[y][x]:
				var tile_coords = Vector2i(x, y)
				var value = noise.get_noise_2d(x, y)  # Output is -1 to 1
				if value > threshold_terreno_1:
					tilemap_1.set_cell(tile_coords, 1, Vector2i(2,1), 0)
				elif value < threshold_terreno_2:
					tilemap_2.set_cell(tile_coords, 1, Vector2i(2,1), 0)


func generate_island_chao(land_map):
	var map_sizef : Vector2 = map_size
	var center = map_sizef / 2

	for y in map_size.y:
		for x in map_size.x:
			var tile_coords = Vector2i(x, y)
			var normalized_pos = (Vector2(x, y) - center) / (map_sizef / 2)
			var distance = normalized_pos.length()

			# Radial falloff function (1.0 at center, 0.0 at edge)
			var falloff = clamp(1.0 - pow(distance, island_radius), 0.0, 1.0)

			# Get noise value and multiply by falloff
			var n = noise.get_noise_2d(x, y) * 0.5 + 0.5  # Normalize to 0–1
			var value = n * falloff

			# Threshold to determine land
			if value > land_threshold:
				land_map[y][x] = true
				tilemap_areia.set_cell(tile_coords, 1, Vector2i(2,1), 0)


func find_largest_region(land_map) -> Array:
	var visited := {}
	var largest_region := []
	for y in map_size.y:
		for x in map_size.x:
			if land_map[y][x] and not visited.has(Vector2i(x, y)):
				var region := flood_fill(land_map, Vector2i(x, y), visited)
				if region.size() > largest_region.size():
					largest_region = region
	return largest_region

# 4-way flood fill
func flood_fill(map_data: Array, start: Vector2i, visited: Dictionary) -> Array:
	var region := []
	var queue := [start]
	visited[start] = true

	while queue.size() > 0:
		var pos = queue.pop_front()
		region.append(pos)

		for offset in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
			var neighbor = pos + offset
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= map_size.x or neighbor.y >= map_size.y:
				continue
			if visited.has(neighbor):
				continue
			if map_data[neighbor.y][neighbor.x]:
				queue.append(neighbor)
				visited[neighbor] = true

	return region

func _criar_matriz_bool(matriz : Array, start_state : bool = false) -> void:
	for y in map_size.y:
		var linha : Array = []
		linha.resize(map_size.x)
		linha.fill(start_state)
		matriz.append(linha)

func _coord_to_global_pos(coord : Vector2i) -> Vector2:
	var pos = tilemap_areia.map_to_local(coord)
	return tilemap_areia.to_global(pos)
