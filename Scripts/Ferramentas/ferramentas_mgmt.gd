extends Node2D

#const ref_corte   = preload("res://Cenas/Ferramentas/Corte.tscn")
#const ref_planta  = preload("res://Cenas/Ferramentas/Corte.tscn")
#const ref_recolhe = preload("res://Cenas/Ferramentas/Recolher.tscn")

func jogador_pegar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	#ferramenta.queue_free()
	
	ferramenta.hide_ferramenta()
	
	remove_child(ferramenta)
	jogador.add_child(ferramenta)

func jogador_soltar(jogador : Node2D, ferramenta : Ferramenta) -> void:
	#ferramentas_mgmt.spawn_ferramenta(ferramenta, pos_ferramenta)
	
	jogador.remove_child(ferramenta)
	add_child(ferramenta)
	
	ferramenta.show_ferramenta()
	
	# spawn a ferramenta no chao
	var pos_ferramenta = jogador.global_position + Vector2(-15, 40)
	_position_ferramenta(ferramenta, pos_ferramenta)

func _position_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	var ferramenta_inst : Node2D = ferramenta
	ferramenta_inst.global_position = global_pos

#func spawn_ferramenta(ferramenta : Ferramenta, global_pos : Vector2) -> void:
	## nao eh valido
	#if not ferramenta or (not is_instance_valid(ferramenta)): return
	#
	#var ferramenta_inst : Node2D = ferramenta
	#
	##var ferramenta_inst : Node2D
	##match ferramenta.tipo_ferramenta:
		##Ferramenta.Ferramenta_tipo.CORTAR:
			##ferramenta_inst = ref_corte.instantiate()
		##Ferramenta.Ferramenta_tipo.PLANTAR:
			##ferramenta_inst = ref_planta.instantiate()
		##Ferramenta.Ferramenta_tipo.RECOLHER:
			##ferramenta_inst = ref_recolhe.instantiate()
	#
	## adiciona na tree
	#add_child(ferramenta_inst)
	#ferramenta_inst.global_position = global_pos
	#
	#print("ferramenta ", ferramenta, " em ", global_pos)
