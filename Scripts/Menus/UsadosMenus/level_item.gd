extends Control
class_name LevelItem


@export var medalha_cor : Dictionary[Globais.Medalha_tipo, Color]
## texto antes do tempo, com espaco no final
@export var tempo_text := "Melhor Tempo: "

@onready var level_image := $TextureRect
@onready var label_name := $LevelName
@onready var label_info := $Info/LabelTempo
@onready var medalha_image := $Info/Medalha

var level_id : Globais.Level_id

func btn_grab_focus() -> void:
	grab_focus()

func _on_pressed() -> void:
	SceneManager.goto_level(level_id)

func ajust(_level_id : int) -> void:
	level_id = _level_id
	# Nome do level
	var texto_btn : String = "Sem_Nome" 
	if Globais.LEVEIS_NOME.has(level_id):
		texto_btn = Globais.LEVEIS_NOME[level_id]
	label_name.text = texto_btn
	# info
	_load_info()
	# imagem
	if Globais.LEVEIS_IMAGE.has(level_id):
		level_image.texture = Globais.LEVEIS_IMAGE[level_id]
	

func _load_info() -> void:
	var highscore : int = Globais.leveis_highscore[level_id]
	
	# se nao tem highscore (ou eh invalido) -> nao mostra
	if highscore < 0:
		label_info.hide()
		medalha_image.hide()
		return
	
	# ajusta o texto do tempo
	var min : int = highscore / 60
	var sec : int = highscore % 60
	label_info.text = tempo_text + str(min) + ":" + str(sec)
	
	# ajusta imagem
	var medalha : Globais.Medalha_tipo = Globais.get_medalha_level(level_id, highscore)
	
	# se nao tiver medalha -> esconde a imagem da medalha
	if medalha == Globais.Medalha_tipo.NENHUMA:
		medalha_image.hide()
		return
	
	medalha_image.modulate = medalha_cor[medalha]
