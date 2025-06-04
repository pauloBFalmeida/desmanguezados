extends SubViewportContainer

@export var camera : Camera2D

@onready var subviewport := $SubViewport

func _ready() -> void:
	# resize para o tamanho da tela
	var window_size = get_viewport().get_visible_rect().size
	subviewport.size = window_size # msm tamanho da tela
	# 
	#subviewport.get_texture().flags &= ~SubViewport.FLAG_F  
	
	#get_parent().call_deferred("remove_child", camera)
	#subviewport.call_deferred("add_child", camera)
