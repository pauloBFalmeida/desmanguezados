extends Node2D
class_name SpawnJogadores

@export var ferramentas_mgmt : FerramentaMgmt
@export var tilemaps_chao : TileMapsChao

## segundos atras para respawnar o jogador
@export var respawn_tempo_atras : float = 1.0

var jogadores : Array[Jogador]
var jogadores_spawns : Dictionary[Jogador, Vector2]
var jogadores_atras_pos : Dictionary[Jogador, Array]
@onready var respawn_tempo_atras_ms     := int(respawn_tempo_atras * 1000)
@onready var max_respawn_tempo_atras_ms := int(1.5 * respawn_tempo_atras * 1000)

func _ready() -> void:
	ferramentas_mgmt.tilemaps_chao = tilemaps_chao
	
	for jogador : Jogador in get_children():
		jogadores.append(jogador)
		jogadores_spawns[jogador] = jogador.global_position
		jogadores_atras_pos[jogador] = [] # lista nova de posicoes

func _physics_process(delta: float) -> void:
	for jogador in jogadores:
		# -- jogador na agua --
		var is_on_water : bool = tilemaps_chao.jogador_pos_on_water(jogador.global_position)
		jogador.is_on_water = is_on_water
		
		# -- jogador no lodo --
		var speed_modifier : float = tilemaps_chao.jogador_pos_speed_lodo(jogador.global_position)
		# coloca no jogador o speed modifier
		jogador.set_speed_modifier_terreno(speed_modifier)
		
		# -- posicao do jogador tempo atras --
		if Engine.get_physics_frames() % 3 == 0: # roda 1 vez a cada 3 _physics_process
			salvar_posicao_jogador(jogador)
			

func salvar_posicao_jogador(jogador : Jogador) -> void:
	var current_time = Time.get_ticks_msec()  # milisec da godot
	var lista_pos = jogadores_atras_pos[jogador]
	lista_pos.append({"time": current_time, "global_pos": jogador.global_position})
	# remove o primeiro item da lista se ele for mais antigo do max_respawn_tempo_atras_ms
	if lista_pos.front()["time"] <= current_time - max_respawn_tempo_atras_ms:
		lista_pos.pop_front()

func respawn_jogador(jogador : Jogador) -> void:
	var default_global_pos := jogadores_spawns[jogador] # local onde o jogador spawnou
	var global_pos = _find_global_pos_mais_prox(jogadores_atras_pos[jogador], default_global_pos)
	#
	jogador.global_position = global_pos
	# fade in de respawn 
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		jogador, 
		"modulate:a",
		1.0,
		0.3 # duracao
	).from_current()

func _find_global_pos_mais_prox(lista_pos: Array, default_global_pos : Vector2) -> Vector2:
	var current_time = Time.get_ticks_msec()  # milisec da godot
	var target_time = current_time - respawn_tempo_atras_ms # posicao alvo
	
	var closest_pos = default_global_pos # se nao conseguir nada melhor, mandar o default
	var closest_diff : float = INF
	
	for atras_pos in lista_pos:
		var is_on_water : bool = tilemaps_chao.jogador_pos_on_water(atras_pos["global_pos"])
		if is_on_water: # se estava na agua
			continue # pula essa opcao
		
		var time_diff = target_time - atras_pos["time"]
		# se o tempo foi depois do target_time, i.e. mais recente
		if time_diff < 0:
			time_diff *= 2 # mais recente eh menos atrativo
			
		time_diff = abs(time_diff) # abs para ficar so com a diferenca, sem negativo
		# pega o com a diferenca de tempo
		if time_diff < closest_diff:
			closest_diff = time_diff
			closest_pos = atras_pos["global_pos"]
	
	return closest_pos

func get_ferramentas_mgmt() -> FerramentaMgmt:
	return ferramentas_mgmt
