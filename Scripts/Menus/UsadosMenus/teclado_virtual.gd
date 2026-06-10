@abstract
class_name TecladoVirtual
extends Control

signal fechar_pressed
signal corrigir_pressed
signal char_pressed(_char: String)
signal clear_pressed

enum Tipo {NUMERICO, NOMES}

@export var foco_inicial: Control

# -----------------------------------------------------------------------------
func _fechar_apertado() -> void:
	fechar_pressed.emit()

func _corrigir_apertado() -> void:
	corrigir_pressed.emit()

func _apertar(_char: String) -> void:
	char_pressed.emit(_char)
