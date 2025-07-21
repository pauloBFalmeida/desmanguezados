extends Level

@export var ui_infos : Array[Informacao]
var info_por_jogador : Dictionary[Jogador, Informacao] = {}

func _ready() -> void:
	super()
	# preprar o dict info_por_jogador
	for info in ui_infos:
		var jogador : Jogador = info.get_parent()
		info_por_jogador[jogador] = info

func _on_area_2d_jogar_body_entered(body: Node2D) -> void:
	if body is Jogador:
		var jogador : Jogador = body
		# esta segurando uma ferramenta valida
		if jogador.get_segurando_valido():
			# tem 1 uso valido
			if info_por_jogador.has(jogador):
				# Informacao tomar acao
				info_por_jogador[jogador].tomar_acao(jogador)
				# remove do dict
				info_por_jogador.erase(jogador)
