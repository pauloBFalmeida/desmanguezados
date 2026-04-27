extends SistemaOnline

@export var gerenciador_partida: GerenciadorPartida

var arvore_por_id : Dictionary[int, Arvore] = {}
var lixo_por_id : Dictionary[int, Lixo] = {}
var locais_plantar_por_id : Dictionary[int, Node2D] = {}

func iniciar_online_config() -> void:
	iniciar_arvores()
	iniciar_lixo()
	iniciar_locais_plantar()

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


#-------------------------------------------------------------------------------
# Locais Plantar Arvores
#-------------------------------------------------------------------------------

# ==== Explicacao do plantar
#	Usar a ferramenta de plantar -- chama --> LocalPlantarColecao.plantar_muda(local_plantar)
#	O LocalPlantarColecao emite os sinais:
#			plantar(global_position) -> pego pelo ferramentaMgmt
#			plantado_local_plantar(local_plantar) -> pego pelo PartidaOnline (aqui)
#	
#	plantado_local_plantar -- conectado --> _plantar
#	_plantar -- envia --> RPC plantar_id
#	RPC plantar_id -- chama --> chama LocalPlantarColecao.plantar_muda(local_plantar)
#	
#	Isso cria um ciclo, por isso ter essas multiplas verificacoes
#		pra ver se o local que estamos falando eh valido ou eh repetido (neste caso, ignorar)
# ====


var curr_locais_plantar_id: int = 0

func iniciar_locais_plantar() -> void:
	# criar o dict de locais de plantar
	curr_locais_plantar_id = 0
	for local : Node2D in gerenciador_partida.locais_plantar_colecao.get_children():
		_ajustar_local_plantar(local)
	gerenciador_partida.locais_plantar_colecao.criado_local_plantar.connect(_ajustar_local_plantar)
	# ato de plantar a muda
	gerenciador_partida.locais_plantar_colecao.plantado_local_plantar.connect(_plantar)

## Para cada local, coloca o id mais atual no meta data, e salva no dict locais_plantar_por_id
func _ajustar_local_plantar(local: Node2D) -> void:
	var id: int = curr_locais_plantar_id
	# coloca o id no meta data
	local.set_meta("id", id)
	# adiciona no dict
	locais_plantar_por_id[id] = local
	# avanca 1 no id
	curr_locais_plantar_id = id + 1

## Recebe o sinal que foi plantado, e envia o RPC
func _plantar(local: Node2D) -> void:
	# pega o id no local de plantar
	var id : int = local.get_meta("id", -1)
	# se nao tiver o id do local para plantar, pare a funcao
	if (id < 0) or (not locais_plantar_por_id.has(id)): return
	# envia para o outro jogador
	plantar_id.rpc_id(Networking.companion_peer_id, id)

## Recebe que um local foi plantado no outro jogador, e replica a acao neste jogador
@rpc("any_peer", "call_remote", "reliable")
func plantar_id(local_id: int) -> void:
	# se nao tiver o id no dict, pare
	if not locais_plantar_por_id.has(local_id): return
	# pega o local pelo id recebido
	var local: Node2D = locais_plantar_por_id[local_id]
	
	# se ja tiver sido liberado o node, pare
	#	ou o id do node nao eh o mesmo do id recebido, pare
	if not is_instance_valid(local): return
	if local.get_meta("id", -1) != local_id: return
	
	# planta a muda no local de plantar 
	gerenciador_partida.locais_plantar_colecao.plantar_muda(local)
