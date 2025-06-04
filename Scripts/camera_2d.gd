extends Camera2D

@export var texture_viewport : SubViewport
@export var texture_output : Node

func _ready():
	# Wait one frame to avoid blank texture on startup
	await get_tree().process_frame
	#update_shader_texture()
	
	#texture_output.material.set_shader_parameter(
		#"camera_tex", 
		#texture_viewport.get_texture()
	#)

func update_shader_texture():
	# Copy the main viewport to the SubViewport's texture
	var viewport_texture = get_viewport().get_texture()
	
	##texture_viewport.get_texture().copy_from(viewport_texture)
#
	## Pass to shader
	texture_output.material.set_shader_parameter("camera_tex", viewport_texture)
