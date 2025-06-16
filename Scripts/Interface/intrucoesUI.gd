extends Control

@onready var background_rect := $ColorRectBackground
@onready var label := $LabelInstrucoes

enum Icons_tipo {
	CONTROLE_PEGAR, CONTROLE_DROPAR, CONTROLE_USAR,
	CONTROLE_MOVE
}

@export var icones_controle_ps : Dictionary[Icons_tipo, CompressedTexture2D]
@export var icones_controle_xbox : Dictionary[Icons_tipo, CompressedTexture2D]

func _ready() -> void:
	display_texto("Oilha ele aaaaaaaa")
	await get_tree().create_timer(5.0).timeout
	display_texto("yippie")
	await get_tree().create_timer(5.0).timeout
	display_texto("nada nao pai tamo juntooo")
	
func display_icon_texto(texto : String) -> void:
	pass

func display_texto(texto : String) -> void:
	const extra_size := Vector2(8, 2)
	label.text = texto
	# espera o texto atualizar
	await label.resized
	# deixa do msm tamanho do texto
	background_rect.size = label.size
	background_rect.size += extra_size
	# centralize
	background_rect.position = label.position
	background_rect.position -= extra_size/2
	
