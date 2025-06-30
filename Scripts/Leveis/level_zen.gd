extends Level

func _ready() -> void:
	super()
	temporizador.parar() # para de contar o tempo
	# gera o mapa aleatoriamente
	ler_globais_ajustes()
	gerar_mapa_aleatorio()
	ajustar_objetivos() # re ajusta as arvores e tals
	# lidar com a quantidade de jogadores
	lidar_qtd_jogadores_zen()
	# camera zoom
	camera_zoom_in()

# --------------------------------------------- Respawn Ferramentas
func _on_button_respawn_ferramentas_pressed() -> void:
	# pego as ferramentas que estao no chao, ou seja, nenhum jogador esta segurando
	var ferramentas_chao := ferramenta_mgmt.ferramentas_level.duplicate(true)
	for fer_ in ferramenta_mgmt.jogadores_segurando_ferramenta.values():
		ferramentas_chao.erase(fer_)
	
	# spawn ferramentas do chao, proximas do jogador alvo da camera
	# crio um offset da posicao, como inicial para spawnar as ferramentas
	var offset_pos := Vector2.RIGHT * 80
	offset_pos = offset_pos.rotated(randf_range(-PI, PI))
	# posicao do jogador que vai receber as ferramentas
	var jogador_pos = camera_target.global_position
	for fer_ in ferramenta_mgmt.ferramentas_level:
		# posiciono ao redor do jogador
		fer_.global_position = jogador_pos + offset_pos
		offset_pos = offset_pos.rotated(2.094) # roda 360/3 graus
	
	# sai do menu de pause
	hud.despausar()

# --------------------------------------------- Qtd de jogadores
@onready var jogadores := $SpawnJogadores.get_children()

func lidar_qtd_jogadores_zen() -> void:
	if Globais.modo_zen_ter_1_jogador:
		# se o alvo nao esta no controle -> trocar o target para o outro jogador
		if not camera_target.is_usando_controle:
			for jog in jogadores:
				if jog != camera_target:
					camera_target = jog
					break
		# move o outro jogador para longe e desativa ele
		for jog in jogadores:
			if jog != camera_target:
				jog.hide()
				jog.set_physics_process(false)
				jog.set_process(false)
				jog.set_process_input(false)
				jog.global_position = Vector2(-999, -999)

# --------------------------------------------- Camera seguir jogador
@export var max_distance_target : float = 50.0
@export var camera_lerp_speed_curve: Curve
@export var camera_lerp_speed: float = 3.0
@export var camera_target : Jogador
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
@export var map_seed : int = 0
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

## pinos + mangue nao podem maior que 100/9 = 11 (pq cada spawn tira 3x3 de coords)
@export var porcentagem_pinos : float = 7.0
@export var porcentagem_mangue : float = 1.5
## lixo nao podem maior que 100/10 = 10 (pq cada spawn tira 3x3 de coords, e cada arvore tira 1 tile do lixo)
@export var porcentagem_lixo : float = 9.0
# o calculo de 100/(9 + 1) nao eh exatamente veridico mas eh bom o suficiente
# 	seria algo mais como (100 - (pinos+mangue)) / 9 --aprox--> (100-9)/9 = 100/10 

func ler_globais_ajustes() -> void:
	# seed geracao do mapa
	map_seed = Globais.modo_zen_mapa_seed
	# tamanho mapa
	Globais.modo_zen_mapa_size = max(30, Globais.modo_zen_mapa_size) # valor min 40
	map_size = Vector2.ONE * Globais.modo_zen_mapa_size
	# lixo
	porcentagem_lixo = Globais.modo_zen_porcent_lixo
	porcentagem_lixo = min(porcentagem_lixo, 10) # valor maximo 10
	# arvores pinos
	porcentagem_pinos = Globais.modo_zen_porcent_pinos
	porcentagem_pinos = min(porcentagem_pinos, 11) # valor maximo 11
	# arvores mangue
	porcentagem_mangue = Globais.modo_zen_porcent_mangue
	porcentagem_mangue = min(porcentagem_mangue, 11) # valor maximo 11
	# se as arvores juntas passarem de 11 -> faz a soma dar 11
	if porcentagem_pinos + porcentagem_mangue > 11:
		porcentagem_mangue = 11 - porcentagem_pinos

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
	noise.seed = map_seed
	noise.frequency = noise_scale_ilha
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	if map_seed == easter_egg_seed: map_size = Vector2i(70, 70)
	
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
	
	# === Spawn -> posiciona o jogador e ferramentas ===
	gerar_spawn()
	
	# === gera o lixo e as arvores ===
	gerar_objetivos(coords_jogavel, is_jogavel_coods)

# gera e posiciona as arvores e lixo
func gerar_objetivos(coords_jogavel : Array, is_jogavel_coods : Array) -> void:
	var tamanho_mapa = coords_jogavel.size()
	var qtd_pinos  : int = ceil( (tamanho_mapa * porcentagem_pinos)  / 100)
	var qtd_mangue : int = ceil( (tamanho_mapa * porcentagem_mangue) / 100)
	var qtd_lixo   : int = ceil( (tamanho_mapa * porcentagem_lixo)   / 100)
	
	# ajusta as listas de coordenadas de spawn
	# 		pega as coordenadas que sao jogaveis (ja excluindo o spawn)
	#		copia elas para poder usar para spawnar os objetivos no mapa
	#		precisamos da copia pois vamos removendo coordenadas conforme 
	#		spawnamos cada item (o local do item + 3x3 em volta)
	var coords_arvores = coords_jogavel.duplicate(true)
	var coords_lixo = coords_jogavel.duplicate(true)
	coords_arvores.shuffle()
	coords_lixo.shuffle()
	
	# Spawn Arvores Pinos
	while qtd_pinos > 0:
		# posicao que vai spawnar (ja removendo as 3x3 posicoes ao redor)
		var pos = _calc_coord_remover_redor(coords_arvores, coords_lixo)
		if pos == Vector2i.MIN: break #caso acabe as posicoes
		# cria e posiciona as arvores
		var pinos = pinos_ref.instantiate()
		pinos.global_position = pos
		# adiciona a colecao para o level funcionar
		arvores_colecao.add_child(pinos)
		# conta que add uma arvore
		qtd_pinos -= 1
	
	# Spawn Arvores Mangue
	while qtd_mangue > 0:
		# posicao que vai spawnar (ja removendo as 3x3 posicoes ao redor)
		var pos = _calc_coord_remover_redor(coords_arvores, coords_lixo)
		if pos == Vector2i.MIN: break #caso acabe as posicoes
		# cria e posiciona as arvores
		var mangue : Arvore = mangue_ref.instantiate()
		mangue.global_position = pos
		# spawn meia idade
		mangue.idade = Arvore.Crescimento.JOVEM
		# adiciona a colecao para o level funcionar
		arvores_colecao.add_child(mangue)
		# conta que add uma arvore
		qtd_mangue -= 1
	
	# Os spawns das arvores ja retiram do locais de spawn do lixo
	#		para evitar o lixo spawnar no exato msm tile da arvore
	
	# Spawn Lixo
	while qtd_lixo > 0:
		# posicao que vai spawnar (ja removendo as 3x3 posicoes ao redor)
		var pos = _calc_coord_remover_redor(coords_lixo)
		if pos == Vector2i.MIN: break #caso acabe as posicoes
		# cria e posiciona as arvores
		var lixo = lixos_ref.pick_random().instantiate()
		lixo.global_position = pos
		# adiciona a colecao para o level funcionar
		lixos_colecao.add_child(lixo)
		# conta que add um lixo ao mapa
		qtd_lixo -= 1

# pega uma coordenada da lista, remove da lista de coords, e retorna a coordenada do mapa
func _calc_coord_remover_redor(coords_list : Array, coords_list_2 : Array = []) -> Vector2i:
	if coords_list.is_empty(): return Vector2i.MIN
	
	var coord = coords_list.pop_front()
	# verifica os offset
	var x = coord.x
	var y = coord.y
	# se nao for na borda, pode ir o offset de meio tile para os lados do tile
	var cantos = [0, 0, 0, 0] # [cima, esq, baixo, dir]
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
	# impede o lixo de spawnar no exato msm tile da arvore
	coords_list_2.erase( Vector2i(x, y) )
	# retorna
	return pos

# cria a area de spawn (posiciona os jogadores e ferramentas e retira dos locais jogaveis)
func gerar_spawn() -> void:
	# dimensoes do bloco do spawn 
	var tam_up    : int = 2 # -y
	var tam_down  : int = 4 #  y
	var tam_left  : int = 2 # -x
	var tam_right : int = 2 #  x
	# encontra esse bloco
	var centro_coord : Vector2i 
	centro_coord = encontrar_bloco(tam_up, tam_down, tam_left, tam_right)
	
	# posiciona os jogadores
	var pos_jog1 = _coord_to_global_pos(Vector2i(centro_coord.x-1, centro_coord.y-1))
	var pos_jog2 = _coord_to_global_pos(Vector2i(centro_coord.x+1, centro_coord.y+1))
	jogadores[0].global_position = pos_jog1
	jogadores[1].global_position = pos_jog2
	
	# ferramentas
	var pos_fer = [
		_coord_to_global_pos(centro_coord + Vector2i(-2,-2)) + Vector2(-.5, -.5) * tile_size,
		_coord_to_global_pos(centro_coord + Vector2i( 2,-2)) + Vector2( .5, -.5) * tile_size,
		_coord_to_global_pos(centro_coord + Vector2i( 0,-3)),
	]
	for ferram in ferramenta_mgmt.ferramentas_level:
		ferram.global_position = pos_fer.pop_front()
	
	# remove da area jogavel -> para impedir spawnar coisas dentro
	for y_off in range(-tam_down, tam_up+1):
		var y = centro_coord.y + y_off
		for x_off in range(-tam_left, tam_right+1):
			var x = centro_coord.x + x_off
			# remove bloco tamanho_spawn x tamanho_spawn
			is_jogavel_coods[y][x] = false
			coords_jogavel.erase(Vector2i(x,y))

## retorna o centro do bloco
func encontrar_bloco(up, down, left, right) -> Vector2i:
	# fim recursao -> caso nao tinha mais como buscar pq nenhum candidato era valido 
	if up + down + left + right == 4: return Vector2i.ZERO
	
	# cria umas copia das coordenadas da area jogavel
	var coords_busca = coords_jogavel.duplicate(true) 
	coords_busca.shuffle()
	# busca uma bloco de tam x tam
	var buscando := true
	var coord : Vector2i
	while buscando:
		# nao tem mais como buscar -> nao tinha nenhum candidato valido
		if coords_busca.is_empty():
			# diminua o bloco nessa ordem ( ate virar 3x3)
			if down > 1: down -= 1
			elif left > 1: left -= 1
			elif right > 1: right -= 1
			elif up > 1: up -= 1
			return encontrar_bloco(up, down, left, right)
		
		coord = coords_busca.pop_front() # retiramos a base para nao buscar de novo
		var x = coord.x
		var y = coord.y
		if x > left and y > up and x < map_size.x-right and y < map_size.y-down:
			# dizemos que existe e tentamos provar o contrario
			var tem_bloco = true
			for y_off in range(-down, up+1):
				for x_off in range(-left, right+1):
					# nao tem a posicao -> entao bloco nao existe
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
	if map_seed == easter_egg_seed: return easter_egg(land_map)
	
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

## Retorna a regiao dada por coordenadas conectados (1 bloco vertical ou horizontalmente
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

# ------------------------------------------------------------ Easter Egg Map
const easter_egg_seed = 40725

func easter_egg(land_map) -> Array:
	return draw_filled_heart(land_map)

func draw_filled_heart(land_map):
	var scale = 15  # Size of the heart
	const offset = Vector2i(32, 32)  # Center of the heart in tile coordinates

	var div_scale : float = 1/float(scale) # for fast math
	
	# Define the bounding box in tile coordinates
	var min_x = -2.0
	var max_x = 2.0
	var min_y = -2.0
	var max_y = 2.0
	
	var tile_coords : Vector2i
	for y in range(int(min_y * scale), int(max_y * scale)):
		for x in range(int(min_x * scale), int(max_x * scale)):
			var fx = float(x) * div_scale
			var fy = float(y) * div_scale
			if heart_formula(fx, fy):
				# coordenada do tile com o offset
				tile_coords = Vector2i(x, -y) + offset  # Flip y
				# marca no mapa do chao  e  cria o tile
				land_map[tile_coords.y][tile_coords.x] = true
				tilemap_areia.set_cell(tile_coords, 1, Vector2i(2,1), 0)
				
	return land_map

func heart_formula(x: float, y: float) -> bool:
	# Normalize to heart-space [-1, 1]
	var value = pow(x * x + y * y - 1, 3) - x * x * pow(y, 3)
	return value <= 0
