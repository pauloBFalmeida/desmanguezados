extends Control
class_name BarraProgresso

@onready var barra_prog_base := $ProgColorBase
@onready var barra_prog_top := $ProgColorTop
@onready var mostradores := $mostradores
@onready var mostrador_lixo := $mostradores/Lixo
@onready var mostrador_muda := $mostradores/ArvoresMangue

var qtd_total_faltando : int = 1
var qtd_mudas_faltando : int
var qtd_lixo_faltando : int

func _ready() -> void:
	barra_prog_base.scale.x = 0
	# 
	barra_prog_top.scale.x = 0
	mostradores.hide()
	mostradores.position = Vector2.ZERO

func comecar() -> void:
	mostradores.hide()
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

func update_progresso() -> void:
	var prog : float
	prog = qtd_total_faltando - (qtd_mudas_faltando + qtd_lixo_faltando) 
	prog = prog / qtd_total_faltando
	barra_prog_top.scale.x = prog

# ---------------------------- Receber updates dos valores
func ajustar_faltando(qtd_mudas : int, qtd_lixo : int) -> void:
	qtd_total_faltando = qtd_mudas + qtd_lixo

func update_mudas_faltando(qtd_mudas : int) -> void:
	qtd_mudas_faltando = qtd_mudas
	update_progresso()

func update_lixo_faltando(qtd_lixo : int) -> void:
	qtd_lixo_faltando = qtd_lixo
	update_progresso()
