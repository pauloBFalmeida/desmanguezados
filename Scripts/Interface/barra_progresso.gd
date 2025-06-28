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

func _ready() -> void:
	barra_prog_base.scale.x = 0
	# 
	barra_prog_top.scale.x = 0
	mostradores_pivot.hide()

func comecar() -> void:
	mostradores_pivot.hide()
	# animacao de carregar a barra
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		barra_prog_base,
		"scale:x",
		1.0, 		# valor final
		2.0 		# duracao em seg
	).from_current()
	# espera acabar a animacao
	await tween.finished
	# mostra os icones
	mostradores_pivot.show()
	mostrador_lixo.show()
	mostrador_muda.show()
	mostradores_pivot.position.x = 0

func update_progresso() -> void:
	var qtd : int
	qtd  = qtd_total_faltando
	qtd -= qtd_mudas_faltando + qtd_pinos_faltando + qtd_lixo_faltando
	var prog : float = float(qtd) / qtd_total_faltando
	barra_prog_top.scale.x = prog
	
	var posicao_x = barra_prog_top.size.x * barra_prog_top.scale.x
	mostradores_pivot.position.x = posicao_x
	# icones
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
