extends SubViewportContainer

@export var camera : Camera2D

@onready var subviewport := $SubViewport

func _ready() -> void:
	pass
	#var window_size = get_viewport().get_visible_rect().size
	#subviewport.size = window_size # msm tamanho da tela
	
	#get_parent().call_deferred("remove_child", camera)
	#subviewport.call_deferred("add_child", camera)
