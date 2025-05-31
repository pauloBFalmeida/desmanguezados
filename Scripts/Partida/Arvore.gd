class_name Arvore
extends RigidBody2D

enum Arvore_tipo {PINOS, MANGUE}

enum Crescimento {BEBE, JOVEM, ADULTA}

@export var idade : Crescimento = Crescimento.BEBE

## tempo em segundos para crescer para a proxima idade
@export var crescimento_time : float = 12.0

func is_adulta() -> bool:
	return idade == Crescimento.ADULTA

func comecar_crescer() -> void:
	if idade == Crescimento.ADULTA: return

func crescer() -> void:
	print("Crescer ", idade)
	
	match (idade):
		Crescimento.BEBE:
			idade = Crescimento.JOVEM
		Crescimento.JOVEM:
			idade = Crescimento.ADULTA
