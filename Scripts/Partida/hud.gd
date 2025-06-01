extends Control
class_name Hud

@onready var label_qtd_mudas := $LabelMudas

func update_mudas(qtd_mudas : int) -> void:
	label_qtd_mudas.text = "Qtde de arvores a serem plantadas: " + str(qtd_mudas)
