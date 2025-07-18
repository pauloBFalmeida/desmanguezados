extends Menu

@onready var btn_voltar := $ButtonVoltar

@onready var container_configs := $VBoxConfigs
@onready var container_tags := $VBoxTags
# -- Controles --
@onready var toggle_controle_p1 := $VBoxConfigs/GridContainerControles/ButtonControleP1
@onready var toggle_controle_p2 := $VBoxConfigs/GridContainerControles/ButtonControleP2
@onready var options_tipos_controles := $VBoxConfigs/GridContainerControles/OptionsTipoControles
# -- GamePlay --
@onready var toggle_aim_all_time := $VBoxConfigs/AimAllTime
@onready var toggle_tracking_color := $VBoxConfigs/TrackingColor
# -- Audio --
@onready var slider_musica_menu := $VBoxConfigs/GridContainerAudio/HSliderMusicaMenu
@onready var slider_musica_partida := $VBoxConfigs/GridContainerAudio/HSliderMusicaPartida
@onready var slider_efeitos_partida := $VBoxConfigs/GridContainerAudio/HSliderEffects
# -- Exibicao --
@onready var toggle_fullscreen := $VBoxConfigs/TelaCheia
@onready var toggle_rem_efeitos_graf := $VBoxConfigs/RemEfeitosGraf
@onready var toggle_rem_logo_intro := $VBoxConfigs/RemLogoIntro
# -- Save --
@onready var toggle_deletar_partida := $VBoxConfigs/GridContainerSave/ButtonDeletarPartida
@onready var toggle_deletar_todo := $VBoxConfigs/GridContainerSave/ButtonDeletarTodo
@onready var label_deletar_partida_certeza := $VBoxConfigs/GridContainerSave/ButtonDeletarPartidaCerteza
@onready var label_deletar_todo_certeza := $VBoxConfigs/GridContainerSave/ButtonDeletarTodoCerteza
@onready var button_deletar_partida_certeza := $VBoxConfigs/GridContainerSave/LabelPartidaCerteza
@onready var button_deletar_todo_certeza := $VBoxConfigs/GridContainerSave/LabelTodoCerteza

# -- Save Dados --
@onready var itens_partida := [button_deletar_partida_certeza, label_deletar_partida_certeza]
@onready var itens_todo := [label_deletar_todo_certeza, button_deletar_todo_certeza]

# ----- Menu de Tags -----
enum Tag {CONTROLES, GAMEPLAY, AUDIO, EXIBICAO, SAVE}
@onready var buttons_por_tag : Dictionary[Tag, Button] = {
	Tag.CONTROLES : $VBoxTags/TagControles,
	Tag.GAMEPLAY  : $VBoxTags/TagGameplay,
	Tag.AUDIO     : $VBoxTags/TagAudio,
	Tag.EXIBICAO  : $VBoxTags/TagExibicao,
	Tag.SAVE      : $VBoxTags/TagSave,
}
## string escrita nos metadados das configuracoes -> Tag
var string_para_tag : Dictionary[String, Tag] = {
	"controles" : Tag.CONTROLES,
	"gameplay"  : Tag.GAMEPLAY,
	"audio"     : Tag.AUDIO,
	"exibicao"  : Tag.EXIBICAO,
	"save"      : Tag.SAVE,
}
var configs_por_tag : Dictionary[Tag, Array]


# --- Voltar ---
func _on_button_voltar_pressed() -> void:
	voltar_menu_principal()
	SaveManager.save_game()

func _ready() -> void:
	btn_voltar.grab_focus()
	# ---
	_ajustar_tags_configs()
	_carregar_dados()
	# mostra no inicio as configuracoes dos controles
	_update_configs_por_tag(Tag.CONTROLES)

# --------- Carregar os dados do disco ---------
func _carregar_dados() -> void:
	# -- Controles --
	_ajustar_options_tipo_controle()
	# -- GamePlay --
	toggle_aim_all_time.set_pressed_no_signal(Globais.possivel_aim_all_time)
	var desativar_transparente : bool = not Globais.indicador_direcao_transparente_sem_target
	toggle_tracking_color.set_pressed_no_signal(desativar_transparente)
	# -- Audio --
	slider_musica_menu.set_value_no_signal(Globais.volume_musica_menu)
	slider_musica_partida.set_value_no_signal(Globais.volume_musica_partida)
	slider_efeitos_partida.set_value_no_signal(Globais.volume_efeitos_partida)
	# -- Exibicao --
	toggle_fullscreen.set_pressed_no_signal(Globais.tela_cheia)
	toggle_rem_efeitos_graf.set_pressed_no_signal(Globais.remov_efeitos_graf)
	toggle_rem_logo_intro.set_pressed_no_signal(Globais.remov_logo_intro)
	# -- Deletar Save --
	_on_button_deletar_partida_toggled(false)
	_on_button_deletar_todo_toggled(false)

# --------- Controles ---------
var controle_player_curr := InputManager.PlayerId.P1
func _on_button_controle_p_1_toggled(toggled_on: bool) -> void:
	if not toggled_on: toggle_controle_p1.set_pressed_no_signal(true)
	
	controle_player_curr = InputManager.PlayerId.P1
	toggle_controle_p2.set_pressed_no_signal(false) # des-aperta o P2
	_ajustar_options_tipo_controle()

func _on_button_controle_p_2_toggled(toggled_on: bool) -> void:
	if not toggled_on: toggle_controle_p2.set_pressed_no_signal(true)
	
	controle_player_curr = InputManager.PlayerId.P2
	toggle_controle_p1.set_pressed_no_signal(false) # des-aperta o P1
	_ajustar_options_tipo_controle()

func _ajustar_options_tipo_controle() -> void:
	options_tipos_controles.clear()
	var tipo_atual := Globais.controle_tipo_player[controle_player_curr]
	for tipo in InputManager.controle_tipo_string.keys():
		# adiciono o item com o nome do tipo de controle
		var texto : String = InputManager.controle_tipo_string[tipo]
		options_tipos_controles.add_item(texto, tipo)
		# se for o tipo atual -> selecione ele
		if tipo == tipo_atual:
			options_tipos_controles.select(tipo)
	

func _on_options_tipo_controles_item_selected(index: int) -> void:
	var tipo : int = options_tipos_controles.get_item_id(index)
	Globais.controle_tipo_player[controle_player_curr] = tipo


# --------- GamePlay ---------
func _on_aim_all_time_toggled(toggled_on: bool) -> void:
	Globais.possivel_aim_all_time = toggled_on
	print("all time set to ", Globais.possivel_aim_all_time)

func _on_tracking_color_toggled(toggled_on: bool) -> void:
	var ficar_transparente : bool = not toggled_on
	Globais.indicador_direcao_transparente_sem_target = ficar_transparente
	print("transparente set to ", Globais.indicador_direcao_transparente_sem_target)

# --------- Audio ---------
func _on_h_slider_musica_menu_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_musica_menu = slider_musica_menu.value
	# ajusta na musica atual do menu
	get_parent().update_volume_musica_menu()

func _on_h_slider_musica_partida_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_musica_partida = slider_musica_partida.value

func _on_h_slider_effects_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	Globais.volume_efeitos_partida = slider_efeitos_partida.value

# --------- Exibicao ---------
func _on_tela_cheia_toggled(toggled_on: bool) -> void:
	Globais.tela_cheia = toggled_on
	Globais.ajustar_tela_cheia()

func _on_rem_efeitos_graf_toggled(toggled_on: bool) -> void:
	Globais.remov_efeitos_graf = toggled_on

func _on_rem_logo_intro_toggled(toggled_on: bool) -> void:
	Globais.remov_logo_intro = toggled_on


# --------- Deletar Save ---------
func _on_button_reset_configs_pressed() -> void:
	SaveManager.reset_globais_config()
	# update visual
	_on_tag_gameplay_toggled(true)

func _on_button_deletar_partida_toggled(toggled_on: bool) -> void:
	lidar_toggle(toggled_on, toggle_deletar_partida, itens_partida)

func _on_button_deletar_todo_toggled(toggled_on: bool) -> void:
	lidar_toggle(toggled_on, toggle_deletar_todo, itens_todo)

func _on_button_deletar_certeza_pressed() -> void:
	# deletar o save
	SaveManager.reset_save()
	# mostrar q deletou
	label_deletar_partida_certeza.text = "Dados deletados!"
	button_deletar_partida_certeza.hide()
	toggle_deletar_partida.hide()
	# volta o cursor para o btn de voltar
	btn_voltar.grab_focus()

func _on_button_deletar_todo_certeza_pressed() -> void:
	# deletar o save
	SaveManager.reset_save()
	# mostrar q deletou
	label_deletar_todo_certeza.text = "Dados deletados!"
	button_deletar_todo_certeza.hide()
	toggle_deletar_todo.hide()
	# volta o cursor para o btn de voltar
	btn_voltar.grab_focus()


func lidar_toggle(toggled_on: bool, toggle_btn : Button, itens : Array) -> void:
	# clicou para deletar
	if toggled_on:
		toggle_btn.text = "Não, manter dados"
		for item in itens:
			item.show()
	else:
		toggle_btn.text = "Deletar"
		for item in itens:
			item.hide()

# --------- Tags ---------
func _ajustar_tags_configs() -> void:
	# cria uma lista vazia para cada tag
	for tag in Tag.values():
		configs_por_tag[tag] = []
	# para cada botao de tag ajusta o receber foco para mesmo de apertar
	buttons_por_tag[Tag.CONTROLES].focus_entered.connect( _on_tag_controles_toggled.bind(true) )
	buttons_por_tag[Tag.GAMEPLAY].focus_entered.connect(  _on_tag_gameplay_toggled.bind(true) )
	buttons_por_tag[Tag.AUDIO].focus_entered.connect(     _on_tag_audio_toggled.bind(true) )
	buttons_por_tag[Tag.EXIBICAO].focus_entered.connect(  _on_tag_exibicao_toggled.bind(true) )
	buttons_por_tag[Tag.SAVE].focus_entered.connect(      _on_tag_save_toggled.bind(true) )
	# ajusta as configs nas tags 
	for config in container_configs.get_children():
		var config_tag : String = config.get_meta("tag")
		var tag = string_para_tag[config_tag]
		# adiciono ao dict de configs por tag
		configs_por_tag[tag].append(config)
	# ajusta movimentos do focus nos neighbors
	_ajustar_tags_focus_neighbors()

func _update_configs_por_tag(tag_mostar : Tag) -> void:
	_unpress_tag_buttons(tag_mostar)
	# 
	for tag in Tag.values():
		for config in configs_por_tag[tag]:
			if tag == tag_mostar:
				config.show()
			else:
				config.hide()

## des-aperta todos os botoes das tags, com excessao do passado como parametro
func _unpress_tag_buttons(except_tag : Tag) -> void:
	# des-aperta todos os botoes de tag
	for btn in buttons_por_tag.values():
		btn.set_pressed_no_signal(false)
	# aperta a excessao
	buttons_por_tag[except_tag].set_pressed_no_signal(true)

func _ajustar_tags_focus_neighbors() -> void:
	for tag in Tag.values():
		# -- Focus Neighbors do botao da tag --
		# pega o botao da tag atual
		var button_tag = buttons_por_tag[tag]
		# pego o primeiro da lista dos Controls de configuracao por tag
		var btn_config : Control = configs_por_tag[tag][0]
		# se for uma grid ou container -> pego o primeiro botao que eu achar
		if btn_config is GridContainer:
			for grid_item in btn_config.get_children():
				# para ao encontrar o primeiro item da grid que for um botao
				if _focus_valid(grid_item):
					btn_config = grid_item
					break
		
		# neighbor direita <-recebe- (o do NodePath do) btn_config
		button_tag.focus_neighbor_right = btn_config.get_path()
		# apertou o botao da tag -> foca no botao btn_config
		button_tag.pressed.connect( func(): btn_config.grab_focus() )
		
		# -- Focus Neighbors dos botoes das configuracoes --
		var button_tag_path = button_tag.get_path()
		
		# ultimo botao de configuracoes dessa tag -recebe-> proximo como botao da tag
		if _focus_valid(configs_por_tag[tag][-1]):
			configs_por_tag[tag][-1].focus_neighbor_right = button_tag_path
			configs_por_tag[tag][-1].focus_neighbor_bottom = button_tag_path
		
		# se for o menu de controles -> pula resto da funcao
		#	como temos 2 botoes horizontais (selecionar player do controle)
		#	nao queremos que apertar esquerda volte para os botoes das tags
		if tag == Tag.CONTROLES: continue 
		
		# todos botoes configuracoes dessa tag recebem botao de tag como neighbor esq
		for config in configs_por_tag[tag]:
			# se for um botao <-recebe- (o do NodePath do) button_tag
			if _focus_valid(config):
				config.focus_neighbor_left = button_tag_path
			# se for uma grid -> pega os botoes presentes nessa grid
			if config is GridContainer:
				for grid_item in config.get_children():
					if _focus_valid(grid_item):
						grid_item.focus_neighbor_left = button_tag_path

func _focus_valid(item : Control) -> bool:
	return (item is Button) or (item is Range) 

# -- btn presses --
func _on_tag_controles_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_update_configs_por_tag(Tag.CONTROLES)

func _on_tag_gameplay_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_update_configs_por_tag(Tag.GAMEPLAY)

func _on_tag_audio_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_update_configs_por_tag(Tag.AUDIO)

func _on_tag_exibicao_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_update_configs_por_tag(Tag.EXIBICAO)

func _on_tag_save_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_update_configs_por_tag(Tag.SAVE)
