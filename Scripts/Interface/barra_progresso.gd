extends Control
class_name BarraProgresso

@onready var barra_prog_base := $ProgColorBase
@onready var barra_prog_top := $ProgColorTop
@onready var mostradores_pivot := $mostradores/pivot
@onready var mostrador_lixo := $mostradores/pivot/Lixo
@onready var mostrador_muda := $mostradores/pivot/ArvoresMangue

@onready var pos_mostrador_1 : Vector2 = mostrador_lixo.position
@onready var pos_mostrador_2 : Vector2 = mostrador_muda.position

var qtd_total_faltando : int = 1
var qtd_mudas_faltando : int
var qtd_lixo_faltando : int
var qtd_pinos_faltando : int

@export var lerp_speed : float = 2.0
var current_prog : float = 0
var target_prog : float = 0
var target_pos_x : float = 0

@export var cor_add : Color = Color.PALE_GREEN
@export var cor_sub : Color = Color.PALE_VIOLET_RED
@onready var cor_normal : Color = barra_prog_top.modulate

func _ready() -> void:
	# pausa enquanto get_tree().pause = true
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	# prepara a barra de baixo pra animacao de comeco
	barra_prog_base.scale.x = 0
	# prepara a barra e os marcadores
	barra_prog_top.scale.x = 0
	mostradores_pivot.hide()

func _process(delta: float) -> void:
	# 
	if not is_equal_approx(barra_prog_top.scale.x, target_prog):
		# barra progresso
		current_prog = lerp(barra_prog_top.scale.x, target_prog, delta*lerp_speed)
		barra_prog_top.scale.x = current_prog
		# mostrador
		mostradores_pivot.position.x = lerp(mostradores_pivot.position.x, target_pos_x, delta*lerp_speed)
	
	# progresso completo -> verificar se precisa mudar de cor
	if abs(target_prog - barra_prog_top.scale.x) < 0.01:
		if barra_prog_top.modulate != cor_normal:
			barra_prog_top.modulate = cor_normal

func comecar(segundos_duracao : int) -> void:
	mostradores_pivot.hide()
	# espera um segundo
	await get_tree().create_timer(1.0, true).timeout
	#segundos_duracao -= 1
	
	# animacao de carregar a barra
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		barra_prog_base,
		"scale:x",
		1.0, 				# valor final
		segundos_duracao	# duracao em seg
	).from_current()
	# espera acabar a animacao
	await tween.finished
	# mostra os icones
	mostradores_pivot.show()
	mostrador_lixo.show()
	mostrador_muda.show()
	mostradores_pivot.position.x = 0
	# animacao
	_anim(mostrador_lixo)
	await get_tree().create_timer(0.2).timeout
	_anim(mostrador_muda)

func _anim(nodo : Node2D, dir : int = -1) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(nodo, "rotation", PI/12 * dir, 2.0)
	tween.finished.connect( _anim.bind(nodo, -dir) )

func update_progresso() -> void:
	# calcula a porcentagem de progresso da barra
	var qtd : int = qtd_total_faltando
	qtd -= qtd_mudas_faltando + qtd_pinos_faltando + qtd_lixo_faltando
	var prog : float = float(qtd) / qtd_total_faltando
	# coloca como o prox progresso
	target_prog = max(0.0, prog)
	
	# -- ve a cor --
	if target_prog > current_prog: # se for positivo (prog calculado > prog atual)
		barra_prog_top.modulate = cor_add
	else: # se for negativo
		barra_prog_top.modulate = cor_sub
	
	
	# calcula a posicao em x dos mostradores
	var posicao_x = barra_prog_top.size.x * target_prog
	target_pos_x = posicao_x
	
	# verifica se deve esconder algum icone s
	if qtd_lixo_faltando <= 0:
		mostrador_lixo.hide()
		mostrador_muda.position = pos_mostrador_1
	if qtd_mudas_faltando <= 0:
		mostrador_muda.hide()
		mostrador_lixo.position = pos_mostrador_1

# ---------------------------- Receber updates dos valores
func ajustar_faltando(qtd_mudas : int, qtd_pinos : int, qtd_lixo : int) -> void:
	qtd_total_faltando = qtd_mudas + qtd_lixo + qtd_pinos
	
	qtd_mudas_faltando = qtd_mudas
	qtd_lixo_faltando  = qtd_lixo
	qtd_pinos_faltando = qtd_pinos

func update_mudas_faltando(qtd_mudas : int) -> void:
	qtd_mudas_faltando = qtd_mudas
	update_progresso()

func update_pinos_faltando(qtd_pinos : int) -> void:
	qtd_pinos_faltando = qtd_pinos
	update_progresso()

func update_lixo_faltando(qtd_lixo : int) -> void:
	qtd_lixo_faltando = qtd_lixo
	update_progresso()
