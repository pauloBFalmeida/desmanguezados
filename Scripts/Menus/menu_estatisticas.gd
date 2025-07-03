extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var label_plantadas := $VBoxContainer/GridContainer/LabelPlantadas
@onready var label_pinos := $VBoxContainer/GridContainer/LabelPinos
@onready var label_lixo := $VBoxContainer/GridContainer/LabelLixo
@onready var label_ferr_pegas := $VBoxContainer/GridContainer/LabelFerrPegas
@onready var label_ferr_jogadas := $VBoxContainer/GridContainer/LabelFerrJogadas
@onready var label_zen_tiles := $VBoxContainer/GridContainerZen/LabelZenTiles


# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	_carregar_dados()

func _carregar_dados() -> void:
	label_plantadas.text = str(Globais.stats_arvores_plantadas)
	label_pinos.text = str(Globais.stats_arvores_pinos_cortadas)
	label_lixo.text = str(Globais.stats_lixos_coletados)
	label_ferr_pegas.text = str(Globais.stats_ferramentas_pegas)
	label_ferr_jogadas.text = str(Globais.stats_ferramentas_jogadas)
	label_zen_tiles.text = str(Globais.stats_zen_tiles_competamente_jogados)
