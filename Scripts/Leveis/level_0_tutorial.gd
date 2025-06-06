extends Level

# Basicamente o codigo inteiro e pra fazer as setas de baixo so aparecerem pro jogador
# que estiver segurando a coisa de plantar
# HAHAHAHA paulo insanity core HAHAHAHAHA

@export var divisor_meio_mapa : Node2D
@export var jogador_emcima : Jogador
@export var jogador_embaixo : Jogador

enum Status_segurando {AMBOS, CIMA, BAIXO, NENHUM}
var curr_status := Status_segurando.NENHUM
var prev_status := Status_segurando.NENHUM

func _ready() -> void:
	super()
	locais_plantar_colecao.comecou_mostrar.connect(ajeitar_locais_plantar_meio_mapa)
	for arvore : Arvore in arvores_colecao.get_children():
		arvore.cortada.connect(ajeitar_locais_plantar_meio_mapa)

func _process(delta: float) -> void:
	if curr_status != Status_segurando.NENHUM:
		update_status()
		if curr_status != prev_status:
			update_mostrar()
	prev_status = curr_status
	
func update_status() -> void:
	var cima := false
	var baixo := false
	if is_instance_valid(jogador_emcima.segurando) and jogador_emcima.segurando != null:
		cima = jogador_emcima.segurando.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR
	if is_instance_valid(jogador_embaixo.segurando) and jogador_embaixo.segurando != null:
		baixo = jogador_embaixo.segurando.tipo_ferramenta == Ferramenta.Ferramenta_tipo.PLANTAR
	
	if cima and baixo:
		curr_status = Status_segurando.AMBOS
	elif cima:
		curr_status = Status_segurando.CIMA
	elif baixo:
		curr_status = Status_segurando.BAIXO
	else:
		curr_status = Status_segurando.NENHUM
	
func ajeitar_locais_plantar_meio_mapa() -> void:
	update_status()
	update_mostrar()

func update_mostrar() -> void:
	match curr_status:
		Status_segurando.AMBOS:
			_mostrar_ambos()
		Status_segurando.CIMA:
			_mostrar_emcima()
		Status_segurando.BAIXO:
			_mostrar_embaixo()
		Status_segurando.NENHUM:
			locais_plantar_colecao.esconder()

func _mostrar_ambos() -> void:
	locais_plantar_colecao._mostrar()

func _mostrar_emcima() -> void:
	for anim in locais_plantar_colecao.animation_nodes:
		# esta na metade de baixo -> esconde
		if anim.global_position.y > divisor_meio_mapa.global_position.y:
			anim.stop()
			anim.hide()
	
func _mostrar_embaixo() -> void:
	for anim in locais_plantar_colecao.animation_nodes:
		# esta na metade de cima -> esconde
		if anim.global_position.y < divisor_meio_mapa.global_position.y:
			anim.stop()
			anim.hide()
