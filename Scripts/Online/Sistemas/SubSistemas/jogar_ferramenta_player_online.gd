class_name JogarFerramentaPlayer
extends Node2D

enum EstadoJogarFerramenta {NENHUM, MIRANDO, JOGANDO}

var jogador : Jogador
var jogar_ferramenta_mgmt : JogarFerramentaMgmt

@export var estado_jogar_ferramenta: EstadoJogarFerramenta = EstadoJogarFerramenta.NENHUM
@export var posicao_mira : Vector2 = Vector2.ZERO :
	set(_pos):
		posicao_mira = _pos
		_update_posicao_mira()

func _update_posicao_mira() -> void:
	if estado_jogar_ferramenta == EstadoJogarFerramenta.MIRANDO:
		jogar_ferramenta_mgmt.mostrar_mira(jogador, posicao_mira)

func atualizar_mirando_pos(global_end_pos: Vector2) -> void:
	posicao_mira = global_end_pos
	# marca que esta mirando
	if estado_jogar_ferramenta != EstadoJogarFerramenta.MIRANDO:
		estado_jogar_ferramenta = EstadoJogarFerramenta.MIRANDO
