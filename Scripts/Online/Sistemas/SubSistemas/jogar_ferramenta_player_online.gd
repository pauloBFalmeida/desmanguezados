class_name JogarFerramentaPlayer
extends Node2D

var jogador : Jogador
var jogar_ferramenta_mgmt : JogarFerramentaMgmt
var ferramenta_mgmt : FerramentaMgmt

enum EstadoJogarFerramenta {NENHUM, MIRANDO, CANCELAR}

@export var estado_jogar : EstadoJogarFerramenta = EstadoJogarFerramenta.NENHUM :
	set(_novo_estado):
		_verificar_novo_estado(_novo_estado)
		estado_jogar = _novo_estado

@export var posicao_mira : Vector2 = Vector2.ZERO :
	set(_pos):
		posicao_mira = _pos
		_update_posicao_mira()

func atualizar_mirando_pos(global_end_pos: Vector2) -> void:
	if estado_jogar != EstadoJogarFerramenta.MIRANDO:
		estado_jogar = EstadoJogarFerramenta.MIRANDO
	
	posicao_mira = global_end_pos

func _update_posicao_mira() -> void:
	if estado_jogar == EstadoJogarFerramenta.MIRANDO:
		jogar_ferramenta_mgmt.mostrar_mira(jogador, posicao_mira)

func _verificar_novo_estado(novo_estado) -> void:
	if estado_jogar == novo_estado: return
	
	match (novo_estado):
		EstadoJogarFerramenta.CANCELAR:
			ferramenta_mgmt.jogador_throw_limpar_predicao(jogador)
