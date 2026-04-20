extends SistemaOnline

@export var gerenciador_partida: GerenciadorPartida

var arvore_por_id : Dictionary[int, Arvore] = {}
var lixo_por_id : Dictionary[int, Lixo] = {}

func iniciar_online_config() -> void:
	iniciar_arvores()
	iniciar_lixo()


#-------------------------------------------------------------------------------
# Arvores
#-------------------------------------------------------------------------------

func iniciar_arvores() -> void:
	var id := 0
	for arvore : Arvore in gerenciador_partida.arvores_colecao.get_children():
		arvore_por_id[id] = arvore
		arvore.cortada.connect(_cortar_arvore.bind(id))
		id += 1

func _cortar_arvore(arvore_id : int) -> void:
	# se nao tem a arvore no dict, retorne
	if not arvore_por_id.has(arvore_id): return
	# remover do dict
	arvore_por_id.erase(arvore_id)
	# matar a arvore no outro jogador
	cortar_arvore.rpc_id(Networking.companion_peer_id, arvore_id)

@rpc("any_peer", "call_remote", "reliable")
func cortar_arvore(arvore_id : int) -> void:
	# se nao tem a arvore no dict, retorne
	if not arvore_por_id.has(arvore_id): return
	# pegar da arvore pelo id
	var arvore := arvore_por_id[arvore_id]
	# se a arvore ainda nao morreu -> mate
	if is_instance_valid(arvore):
		arvore.cortar()
	# remover do dict
	arvore_por_id.erase(arvore_id)


#-------------------------------------------------------------------------------
# Lixo
#-------------------------------------------------------------------------------

func iniciar_lixo() -> void:
	var id := 0
	for lixo : Lixo in gerenciador_partida.lixos_colecao.get_children():
		lixo_por_id[id] = lixo
		lixo.coletado.connect(_coletar_lixo.bind(id))
		id += 1

func _coletar_lixo(lixo_id: int) -> void:
	# se nao esta no dict, retorne
	if not lixo_por_id.has(lixo_id): return
	# remover do dict
	lixo_por_id.erase(lixo_id)
	# matar a arvore no outro jogador
	coletar_lixo.rpc_id(Networking.companion_peer_id, lixo_id)

@rpc("any_peer", "call_remote", "reliable")
func coletar_lixo(lixo_id: int) -> void:
	# se nao esta no dict, retorne
	if not lixo_por_id.has(lixo_id): return
	# pegar o lixo pelo id
	var lixo := lixo_por_id[lixo_id]
	# se a arvore ainda nao morreu -> mate
	if is_instance_valid(lixo):
		lixo.recolher()
	# remover do dict
	lixo_por_id.erase(lixo_id)

