extends Node2D

const ref_corte   = preload("res://Cenas/Ferramentas/Corte.tscn")
const ref_planta  = preload("res://Cenas/Ferramentas/Corte.tscn")
const ref_recolhe = preload("res://Cenas/Ferramentas/Corte.tscn")

func spawn_ferramenta(ferramenta_tipo : Ferramenta.Ferramenta_tipo, global_pos : Vector2) -> void:
	if ferramenta_tipo == Ferramenta.Ferramenta_tipo.NONE: return
	
	var ferramenta_inst : Node2D
	match ferramenta_tipo:
		Ferramenta.Ferramenta_tipo.CORTAR:
			ferramenta_inst = ref_corte.instantiate()
		Ferramenta.Ferramenta_tipo.PLANTAR:
			ferramenta_inst = ref_corte.instantiate()
		Ferramenta.Ferramenta_tipo.LIXO:
			ferramenta_inst = ref_corte.instantiate()
	# adiciona na tree
	add_child(ferramenta_inst)
	ferramenta_inst.global_position = global_pos
	
	print("ferramenta ", ferramenta_tipo, " em ", global_pos)
