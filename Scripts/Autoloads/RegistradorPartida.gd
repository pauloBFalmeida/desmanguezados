extends Node

## ============================================================================
## RegistradorPartida (Autoload)
## ----------------------------------------------------------------------------
## Grava em CSV tudo o que acontece numa partida:
##   - info_partida.csv   -> 1 linha com level, horário de início, duração
##                            máxima configurada (Temporizador.duracao_partida_segundos),
##                            score, tipo de fim e se cada jogador estava
##                            usando controle (essa última é fixa na partida)
##   - jogadores.csv      -> 1 linha por jogador a cada _physics_process com
##                            posição, se está na água, se está parado/andando
##                            e a ferramenta que está segurando
##   - ferramentas.csv    -> 1 linha por evento (pegou/usou/largou/jogou/caiu_chao)
##   - objetos.csv        -> 1 linha por evento de árvore/lixo
##                            (inicio / adicionado / removido), com uma coluna
##                            "origem" marcada "spawn" para quem já existia no
##                            mapa no início da partida
##   - mare.csv           -> 1 linha por _physics_process com o estado da maré
##                            (só é criado se a partida tiver maré)
##
## Cada partida gera uma pasta nova em:
##   user://partidas/partida_<level_id>_<horario>/
##
## Modo zen (level_id == LevelManager.Level_id valor 0): jogadores.csv e
## mare.csv nem são criados — objetos.csv, ferramentas.csv e info_partida.csv
## continuam normalmente. Só nesse modo é criado também:
##   - modo_zen.csv       -> 1 linha com quantidade de jogadores e a config
##                            de geração do mapa (Globais.modo_zen_*)
##
## COMO REGISTRAR (ver instruções completas no final do arquivo):
##   RegistradorPartida.iniciar_partida(level_id, self, controlador_mare)
##   RegistradorPartida.registrar_jogador(jogador)
##   RegistradorPartida.registrar_jogar_ferramenta_mgmt(jogar_ferramenta_mgmt)
##   RegistradorPartida.registrar_objeto_inicial(arvore, "arvore", "nativa")
##   RegistradorPartida.registrar_objeto_adicionado(arvore, "arvore", "nativa")
##   RegistradorPartida.registrar_objeto_removido(arvore, "arvore", "nativa")
##   RegistradorPartida.registrar_objeto_inicial(lixo, "lixo")
## ============================================================================

const PASTA_BASE := "user://partidas/"

# ---------- Referências da partida atual ----------
var _gerenciador: GerenciadorPartida
var _controlador_mare: ControladorMare
var _jogadores: Dictionary = {} # player_id -> Jogador

# ---------- Estado interno ----------
var _partida_ativa := false
var _level_id: String
var _horario_inicio_unix: int
var _horario_inicio_str: String
var _pasta_partida: String
var _tem_mare := false
var _is_modo_zen := false # modo zen não grava posição de jogador nem maré
var _duracao_maxima_segundos := -1 # Temporizador.duracao_partida_segundos, capturado no início

var _arquivo_jogadores: FileAccess
var _arquivo_mare: FileAccess
var _arquivo_objetos: FileAccess
var _arquivo_ferramentas: FileAccess

var _contador_objetos := 0
var _id_objeto_por_node: Dictionary = {} # Node -> String (id estável)
var _origem_objeto_por_node: Dictionary = {} # Node -> String ("spawn" se já existia no início)


func _ready() -> void:
	# só processa fisica enquanto houver partida ativa
	set_physics_process(false)


func _exit_tree() -> void:
	_finalizar_arquivos()


# =====================================================================
# API pública
# =====================================================================

## Chame no _ready() da cena da partida, depois que o GerenciadorPartida
## e o ControladorMare (se existir) já estiverem prontos.
## controlador_mare pode ser null se o mapa não tiver maré.
func iniciar_partida(level_id: LevelManager.Level_id, gerenciador: GerenciadorPartida, controlador_mare: ControladorMare = null) -> void:
	_finalizar_arquivos() # segurança, caso uma partida anterior não tenha sido fechada certo

	_level_id = str(level_id)
	_gerenciador = gerenciador
	_controlador_mare = controlador_mare
	_tem_mare = controlador_mare != null
	_is_modo_zen = level_id == 0
	_duracao_maxima_segundos = -1
	if is_instance_valid(gerenciador) and is_instance_valid(gerenciador.temporizador):
		_duracao_maxima_segundos = gerenciador.duracao_partida_segundos

	_jogadores.clear()
	_id_objeto_por_node.clear()
	_origem_objeto_por_node.clear()
	_contador_objetos = 0

	_horario_inicio_unix = Time.get_unix_time_from_system()
	_horario_inicio_str = Time.get_datetime_string_from_system()

	var nome_pasta := "partida_%s_%s" % [_horario_inicio_str.replace(":", "-"), _level_id]
	_pasta_partida = PASTA_BASE.path_join(nome_pasta)
	DirAccess.make_dir_recursive_absolute(_pasta_partida)

	_abrir_arquivos()

	if not _gerenciador.final_partida.is_connected(_on_final_partida):
		_gerenciador.final_partida.connect(_on_final_partida)
	# se a cena for trocada/reiniciada sem passar por final_partida (ex: botão
	# de "reiniciar" que só dá reload na cena), paramos de gravar assim que o
	# gerenciador começa a sair da árvore, antes dele (e os jogadores) serem
	# efetivamente liberados da memória.
	if not _gerenciador.tree_exiting.is_connected(_on_gerenciador_saiu_da_arvore):
		_gerenciador.tree_exiting.connect(_on_gerenciador_saiu_da_arvore)

	_partida_ativa = true
	set_physics_process(true)


## Registra um jogador para ter posição/estado gravados a cada frame de física
## e conecta os sinais de ferramenta dele.
func registrar_jogador(jogador: Jogador) -> void:
	_jogadores[jogador.player_id] = jogador

	if not jogador.pegou_ferramenta.is_connected(_on_pegou_ferramenta):
		jogador.pegou_ferramenta.connect(_on_pegou_ferramenta.bind(jogador))
	if not jogador.usou_ferramenta.is_connected(_on_usou_ferramenta):
		jogador.usou_ferramenta.connect(_on_usou_ferramenta.bind(jogador))
	if not jogador.largou_ferramenta.is_connected(_on_largou_ferramenta):
		jogador.largou_ferramenta.connect(_on_largou_ferramenta.bind(jogador))


## Conecta ao sinal jogador_jogou_ferramenta do seu JogarFerramentaMgmt, que já
## fornece a ferramenta jogada e a posição final do arremesso — usado pra
## calcular força (distância) e direção (vetor normalizado) do lançamento.
func registrar_jogar_ferramenta_mgmt(mgmt: JogarFerramentaMgmt) -> void:
	if not mgmt.jogador_jogou_ferramenta.is_connected(_on_jogador_jogou_ferramenta_mgmt):
		mgmt.jogador_jogou_ferramenta.connect(_on_jogador_jogou_ferramenta_mgmt)
	if not mgmt.ferramenta_caiu_chao.is_connected(_on_ferramenta_caiu_chao):
		mgmt.ferramenta_caiu_chao.connect(_on_ferramenta_caiu_chao)


## Objeto que já existia no mapa quando a partida começou.
## Fica marcado com origem "spawn", que se repete nos eventos de adicionado/
## removido futuros desse mesmo objeto (ex: uma árvore que já nasceu no mapa
## e depois foi cortada continua marcada como "spawn" no evento de remoção).
func registrar_objeto_inicial(objeto: Node2D, tipo: String, subtipo: String = "") -> void:
	_origem_objeto_por_node[objeto] = "spawn"
	_registrar_evento_objeto(objeto, tipo, subtipo, "inicio")

## Objeto que foi adicionado durante a partida (planta uma muda, joga lixo no chão etc).
func registrar_objeto_adicionado(objeto: Node2D, tipo: String, subtipo: String = "") -> void:
	if not _origem_objeto_por_node.has(objeto):
		_origem_objeto_por_node[objeto] = ""
	_registrar_evento_objeto(objeto, tipo, subtipo, "adicionado")

## Objeto que foi removido durante a partida (árvore cortada, lixo coletado).
## Chame ANTES de o node ser destruído/removido da árvore, senão global_position falha.
func registrar_objeto_removido(objeto: Node2D, tipo: String, subtipo: String = "") -> void:
	_registrar_evento_objeto(objeto, tipo, subtipo, "removido")


## Abre no explorador de arquivos do sistema (Windows, Linux, macOS) a pasta
## onde os CSVs de todas as partidas ficam salvos. Use isso no botão de
## configurações. Se a pasta ainda não existir (o jogo nunca salvou nada),
## ela é criada vazia antes de abrir.
func abrir_pasta_partidas() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA_BASE)
	var caminho_absoluto := ProjectSettings.globalize_path(PASTA_BASE)
	var erro := OS.shell_open(caminho_absoluto)
	if erro != OK:
		push_error("RegistradorPartida: não foi possível abrir a pasta (%s) - %s" % [caminho_absoluto, erro])


## Chame no fim da partida caso você já tenha o score calculado
## e não queira depender só do sinal final_partida do GerenciadorPartida.
func finalizar_partida(tipo_fim, tempo_partida, score = null) -> void:
	if not _partida_ativa:
		return
	_escrever_info_partida(tipo_fim, tempo_partida, score)
	_escrever_modo_zen()
	_finalizar_arquivos()
	_partida_ativa = false
	set_physics_process(false)


## Chame explicitamente sempre que a partida for interrompida sem um fim
## "normal" (reiniciar, sair pro menu, trocar de fase pausando/matando a
## cena). Diferente de finalizar_partida(), não escreve duração/score no
## info_partida.csv — só fecha os arquivos e limpa as referências, com
## segurança. Chame ANTES de reiniciar/recriar jogadores ou o gerenciador,
## para garantir que não sobrem referências antigas.
func parar_partida() -> void:
	if not _partida_ativa:
		return
	var tempo := _tempo_atual() # calcula ANTES de largar a referência do gerenciador
	_escrever_info_partida("interrompida", tempo, null)
	_escrever_modo_zen()
	set_physics_process(false)
	_finalizar_arquivos()
	_partida_ativa = false
	_gerenciador = null
	_controlador_mare = null
	_jogadores.clear()


# =====================================================================
# Loop de física: posição dos jogadores + maré
# =====================================================================

func _physics_process(_delta: float) -> void:
	if not _partida_ativa:
		return

	# rede de segurança: se por algum motivo a partida foi encerrada/reiniciada
	# sem chamar parar_partida() nem disparar tree_exiting (ex: o gerenciador
	# foi reaproveitado e reiniciado no lugar), paramos sozinhos aqui.
	if not is_instance_valid(_gerenciador):
		parar_partida()
		return

	if _is_modo_zen:
		return # modo zen não grava posição de jogador nem maré

	var tempo := _tempo_atual()

	for player_id in _jogadores.keys():
		var jogador: Jogador = _jogadores[player_id]
		if not is_instance_valid(jogador):
			continue

		var movimento := "parado" if jogador.move_dir.is_zero_approx() else "andando"
		var ferramenta_atual : String = jogador.segurando.name if jogador.segurando != null else ""

		var linha := "%.3f,%s,%.2f,%.2f,%s,%s,%s\n" % [
			tempo,
			InputManager.PlayerId.keys()[player_id],
			jogador.global_position.x,
			jogador.global_position.y,
			jogador.is_on_water,
			movimento,
			ferramenta_atual,
		]
		_arquivo_jogadores.store_string(linha)

	if _tem_mare and is_instance_valid(_controlador_mare) and _arquivo_mare != null:
		var linha_mare := "%.3f,%s\n" % [tempo, ControladorMare.Mare.keys()[_controlador_mare.mare_atual]]
		_arquivo_mare.store_string(linha_mare)



# =====================================================================
# Sinais de ferramenta
# =====================================================================

func _on_pegou_ferramenta(ferramenta: Ferramenta, jogador: Jogador) -> void:
	_registrar_evento_ferramenta(jogador, ferramenta, "pegou", jogador.global_position)

func _on_usou_ferramenta(ferramenta: Ferramenta, body: Node2D, jogador: Jogador) -> void:
	_registrar_evento_ferramenta(jogador, ferramenta, "usou", jogador.global_position, body)

func _on_largou_ferramenta(ferramenta: Ferramenta, jogador: Jogador) -> void:
	_registrar_evento_ferramenta(jogador, ferramenta, "largou", jogador.global_position)

func _on_jogador_jogou_ferramenta_mgmt(jogador: Jogador, ferramenta: Ferramenta, global_end_pos: Vector2) -> void:
	var origem_pos := jogador.global_position
	var distancia := origem_pos.distance_to(global_end_pos)
	var direcao := (global_end_pos - origem_pos).normalized()
	_registrar_evento_ferramenta(jogador, ferramenta, "jogou", origem_pos, null, distancia, direcao)

## a ferramenta bateu no chão depois do arremesso (sem jogador associado)
func _on_ferramenta_caiu_chao(ferramenta: Ferramenta, global_pos: Vector2) -> void:
	_registrar_evento_ferramenta(null, ferramenta, "caiu_chao", global_pos)

func _registrar_evento_ferramenta(jogador, ferramenta, acao: String, posicao: Vector2, alvo: Node2D = null, forca = null, direcao = null) -> void:
	if not _partida_ativa or _arquivo_ferramentas == null:
		return
	var tempo := _tempo_atual()
	var nome_ferramenta := str(ferramenta.name) if ferramenta != null else ""
	var nome_alvo := str(alvo.name) if alvo != null else ""
	var player_id_str : String = InputManager.PlayerId.keys()[jogador.player_id] if jogador != null else ""
	var forca_str := "%.3f" % forca if forca != null else ""
	var direcao_x_str := "%.3f" % direcao.x if direcao != null else ""
	var direcao_y_str := "%.3f" % direcao.y if direcao != null else ""
	var linha := "%.3f,%s,%s,%s,%.2f,%.2f,%s,%s,%s,%s\n" % [
		tempo,
		player_id_str,
		nome_ferramenta,
		acao,
		posicao.x,
		posicao.y,
		nome_alvo,
		forca_str,
		direcao_x_str,
		direcao_y_str,
	]
	_arquivo_ferramentas.store_string(linha)


# =====================================================================
# Objetos (árvores / lixo)
# =====================================================================

func _obter_id_objeto(objeto: Node2D, tipo: String) -> String:
	if not _id_objeto_por_node.has(objeto):
		_contador_objetos += 1
		_id_objeto_por_node[objeto] = "%s_%d" % [tipo, _contador_objetos]
	return _id_objeto_por_node[objeto]

func _registrar_evento_objeto(objeto: Node2D, tipo: String, subtipo: String, evento: String) -> void:
	if not _partida_ativa or _arquivo_objetos == null:
		return
	if not is_instance_valid(objeto):
		return
	var id := _obter_id_objeto(objeto, tipo)
	var tempo := _tempo_atual()
	var origem: String = _origem_objeto_por_node.get(objeto, "")
	var linha := "%.3f,%s,%s,%s,%.2f,%.2f,%s,%s\n" % [
		tempo, tipo, id, subtipo,
		objeto.global_position.x, objeto.global_position.y,
		evento, origem,
	]
	_arquivo_objetos.store_string(linha)


# =====================================================================
# Fim de partida (via sinal do GerenciadorPartida)
# =====================================================================

## Chamado quando a cena da partida é destruída (reiniciar, sair pro menu,
## trocar de fase) sem ter emitido final_partida antes. Para tudo com
## segurança enquanto os nodes ainda são válidos, evitando acessar jogadores/
## temporizador já liberados nos próximos frames.
func _on_gerenciador_saiu_da_arvore() -> void:
	parar_partida()

func _on_final_partida(tipo: int, tempo_partida: int = -1) -> void:
	# hoje o GerenciadorPartida só emite o segundo argumento (tempo_partida)
	# na vitória "limpa" — nos outros casos ele chega com -1 aqui.
	# ideal seria emitir sempre os dois argumentos no emit_signal.
	var tempo := tempo_partida
	if tempo < 0 and is_instance_valid(_gerenciador) and is_instance_valid(_gerenciador.temporizador):
		tempo = _gerenciador.temporizador.tempo_restante
	finalizar_partida(tipo, tempo)


func _escrever_info_partida(tipo_fim, tempo_partida, score) -> void:
	var caminho := _pasta_partida.path_join("info_partida.csv")
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	if arquivo == null:
		push_error("RegistradorPartida: não foi possível salvar info_partida.csv (%s)" % FileAccess.get_open_error())
		return

	var tipo_fim_nome := ""
	if tipo_fim is String:
		tipo_fim_nome = tipo_fim
	elif tipo_fim != null and int(tipo_fim) >= 0:
		tipo_fim_nome = GerenciadorPartida.TipoFim.keys()[tipo_fim]

	var score_final = score
	if score_final == null:
		# ajuste aqui pra pegar o score real do seu jogo, se for diferente do tempo
		score_final = tempo_partida

	var duracao_str := str(_duracao_maxima_segundos) if _duracao_maxima_segundos >= 0 else ""

	var cabecalho := "level_id,horario_inicio,duracao_segundos,score,tipo_fim,tem_mare"
	var linha := "%s,%s,%s,%s,%s,%s" % [_level_id, _horario_inicio_str, duracao_str, score_final, tipo_fim_nome, _tem_mare]

	for player_id in _jogadores.keys():
		var jogador: Jogador = _jogadores[player_id]
		cabecalho += ",usando_controle_%s" % InputManager.PlayerId.keys()[player_id]
		linha += ",%s" % (jogador.is_usando_controle if is_instance_valid(jogador) else "")

	arquivo.store_string(cabecalho + "\n")
	arquivo.store_string(linha + "\n")
	arquivo.close()


## Só grava algo se a partida for modo zen. Guarda a config de geração do
## mapa (Globais) e quantos jogadores participaram, já que jogadores.csv não
## é criado nesse modo.
func _escrever_modo_zen() -> void:
	if not _is_modo_zen:
		return

	var caminho := _pasta_partida.path_join("modo_zen.csv")
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	if arquivo == null:
		push_error("RegistradorPartida: não foi possível salvar modo_zen.csv (%s)" % FileAccess.get_open_error())
		return

	arquivo.store_string("qtd_jogadores,mapa_seed,mapa_size,porcent_pinos,porcent_mangue,porcent_lixo\n")
	arquivo.store_string("%d,%d,%d,%.2f,%.2f,%.2f\n" % [
		1 if Globais.modo_zen_ter_1_jogador else 2,
		Globais.modo_zen_mapa_seed,
		Globais.modo_zen_mapa_size,
		Globais.modo_zen_porcent_pinos,
		Globais.modo_zen_porcent_mangue,
		Globais.modo_zen_porcent_lixo,
	])
	arquivo.close()


# =====================================================================
# Utilidades
# =====================================================================

func _tempo_atual() -> float:
	if is_instance_valid(_gerenciador) and is_instance_valid(_gerenciador.temporizador):
		return float(_gerenciador.temporizador.tempo_restante)
	return float(Time.get_unix_time_from_system() - _horario_inicio_unix)

func _abrir_arquivos() -> void:
	# modo zen não grava posição de jogador nem maré
	if not _is_modo_zen:
		_arquivo_jogadores = FileAccess.open(_pasta_partida.path_join("jogadores.csv"), FileAccess.WRITE)
		_arquivo_jogadores.store_string("tempo,player_id,pos_x,pos_y,na_agua,movimento,ferramenta_atual\n")

	_arquivo_objetos = FileAccess.open(_pasta_partida.path_join("objetos.csv"), FileAccess.WRITE)
	_arquivo_objetos.store_string("tempo,tipo,id,subtipo,pos_x,pos_y,evento,origem\n")

	_arquivo_ferramentas = FileAccess.open(_pasta_partida.path_join("ferramentas.csv"), FileAccess.WRITE)
	_arquivo_ferramentas.store_string("tempo,player_id,ferramenta,acao,pos_x,pos_y,alvo,forca,direcao_x,direcao_y\n")

	if _tem_mare and not _is_modo_zen:
		_arquivo_mare = FileAccess.open(_pasta_partida.path_join("mare.csv"), FileAccess.WRITE)
		_arquivo_mare.store_string("tempo,estado_mare\n")

func _finalizar_arquivos() -> void:
	for f in [_arquivo_jogadores, _arquivo_objetos, _arquivo_ferramentas, _arquivo_mare]:
		if f != null:
			f.close()
	_arquivo_jogadores = null
	_arquivo_objetos = null
	_arquivo_ferramentas = null
	_arquivo_mare = null


## ============================================================================
## COMO INTEGRAR NO SEU PROJETO
## ============================================================================
##
## 1) Project Settings > Autoload > adicione este script com o nome
##    "RegistradorPartida" (é assim que você vai chamá-lo em qualquer script:
##    RegistradorPartida.iniciar_partida(...)).
##
## 2) No GerenciadorPartida.gd, no _ready() (ou onde os jogadores já existem):
##
##      func _ready() -> void:
##          var controlador_mare : ControladorMare = get_node_or_null("../Mare")
##          RegistradorPartida.iniciar_partida(Globais.current_level_id, self, controlador_mare)
##          for jogador in jogadores_por_player_id.values():
##              RegistradorPartida.registrar_jogador(jogador)
##
##    (controlador_mare fica null se o mapa não tiver maré, e o get_node_or_null
##    evita erro nesse caso — ajuste o caminho "../Mare" pra onde o node estiver)
##
## 3) Em ajustar_arvores(), depois de conectar os sinais de cada árvore:
##
##      RegistradorPartida.registrar_objeto_inicial(
##          arvore, "arvore", "invasora" if arvore.is_invasora else "nativa"
##      )
##
## 4) Em plantada_arvore_nativa():
##
##      RegistradorPartida.registrar_objeto_adicionado(arvore, "arvore", "nativa")
##
## 5) Em _update_arvore_cortada(arvore) (chamado quando a árvore é cortada):
##
##      RegistradorPartida.registrar_objeto_removido(
##          arvore, "arvore", "invasora" if arvore.is_invasora else "nativa"
##      )
##      # chame isso ANTES de spawn_local_plantar, e antes da árvore sair da árvore de nodes
##
## 6) Em ajustar_lixo():
##
##      RegistradorPartida.registrar_objeto_inicial(lixo, "lixo")
##
## 7) Em colocado_lixo():
##
##      RegistradorPartida.registrar_objeto_adicionado(lixo, "lixo")
##
## 8) Em _coletado_lixo(): esse sinal hoje não informa QUAL lixo foi coletado.
##    Sugestão: mude `signal coletado` para `signal coletado(lixo: Lixo)` no
##    Lixo.gd, emita com `coletado.emit(self)`, e conecte assim em ajustar_lixo/
##    colocado_lixo:
##
##      lixo.coletado.connect(_coletado_lixo.bind(lixo))
##
##    e então, dentro de _coletado_lixo(lixo):
##
##      RegistradorPartida.registrar_objeto_removido(lixo, "lixo")
##
## 9) Pra gravar força e direção de quando o jogador joga a ferramenta, registre
##    também o seu JogarFerramentaMgmt (uma vez só). Pode ser direto no
##    _ready() dele mesmo, passando self:
##
##      # em JogarFerramentaMgmt.gd
##      func _ready() -> void:
##          RegistradorPartida.registrar_jogar_ferramenta_mgmt(self)
##
##    Isso usa o sinal jogador_jogou_ferramenta(jogador, ferramenta, global_end_pos)
##    que essa classe já emite. Força = distância entre a posição do jogador e
##    global_end_pos; direção = vetor normalizado entre os dois pontos.
##
## 10) Fim de partida: já é automático. RegistradorPartida se conecta ao sinal
##    final_partida do GerenciadorPartida assim que iniciar_partida() é chamado.
##    Único cuidado: hoje o fim_partida() só passa `tempo_partida` no caso de
##    VITORIA_LIMPO. Para o score/duração saírem certos no info_partida.csv em
##    TODOS os casos, mude fim_partida() para sempre emitir os dois argumentos:
##
##      emit_signal("final_partida", TipoFim.DERROTA_TEMPO, tempo_partida)
##      emit_signal("final_partida", TipoFim.VITORIA_SUJO, tempo_partida)
##      emit_signal("final_partida", TipoFim.VITORIA_LIMPO, tempo_partida)
##
## 11) IMPORTANTE — reiniciar a partida / voltar pro menu / trocar de fase:
##     chame RegistradorPartida.parar_partida() logo no início dessa lógica,
##     ANTES de reiniciar ou destruir o GerenciadorPartida/jogadores. Isso é
##     necessário mesmo com o tree_exiting conectado automaticamente, porque
##     se o seu "reiniciar" reaproveita a mesma instância do GerenciadorPartida
##     (só reseta o estado dela) em vez de recarregar a cena inteira, o
##     tree_exiting nunca dispara e o registrador não saberia que a partida
##     antiga acabou:
##
##      func reiniciar_partida() -> void: # ou sair_para_menu(), etc.
##          RegistradorPartida.parar_partida()
##          # ... sua lógica de reinício/troca de cena aqui
##
## 12) Os CSVs ficam em user://partidas/partida_<level>_<horario>/. Em desktop
##     isso mapeia pra uma pasta real (%APPDATA% no Windows, ~/.local/share no
##     Linux, etc — use OS.get_user_data_dir() pra achar o caminho exato).
##
## 13) Botão "Abrir pasta de partidas" na tela de configurações:
##
##      # no script da tela de Configurações
##      func _on_botao_abrir_pasta_pressed() -> void:
##          RegistradorPartida.abrir_pasta_partidas()
## ============================================================================
