class_name Arvore
extends StaticBody2D

signal cortada

enum Arvore_tipo {PINOS, MANGUE}

enum Crescimento {BEBE, JOVEM, ADULTA}

@export var is_invasora : bool

@export var idade : Crescimento = Crescimento.BEBE

## tempo em segundos para crescer para a proxima idade
@export var crescimento_time : float = 12.0

var viva : bool = true

func _ready() -> void:
	add_to_group("Arvore")

func is_adulta() -> bool:
	return idade == Crescimento.ADULTA

func comecar_crescer() -> void:
	if idade == Crescimento.ADULTA: return

func crescer() -> void:	
	match (idade):
		Crescimento.BEBE:
			idade = Crescimento.JOVEM
		Crescimento.JOVEM:
			idade = Crescimento.ADULTA

func morrer() -> void:
	hide()
	emit_signal("cortada")
	queue_free()

# --- Abstrato ---
func cortar() -> void:
	pass
