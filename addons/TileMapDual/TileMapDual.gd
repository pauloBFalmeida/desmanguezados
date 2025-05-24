@tool
@icon('TileMapDual.svg')
class_name TileMapDual
extends TileMapLayer


var _ghost_material: Material = preload("res://addons/TileMapDual/ghost_material.tres")

## Material for the display tilemap.
@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "ShaderMaterial, CanvasItemMaterial")
var display_material: Material:
	get:
		return display_material
	set(new_material): # Custom setter so that it gets copied
		display_material = new_material
		changed.emit()

var _tileset_watcher: TileSetWatcher
var _display: Display
func _ready() -> void:
	_tileset_watcher = TileSetWatcher.new(tile_set)
	_display = Display.new(self, _tileset_watcher)
	add_child(_display)
	_make_self_invisible()
	if Engine.is_editor_hint():
		_tileset_watcher.atlas_autotiled.connect(_atlas_autotiled, 1)
		set_process(true)
	else: # Run in-game using signals for better performance
		changed.connect(_changed, 1)
		set_process(false)
	# Update full tileset on first instance
	await get_tree().process_frame
	_changed()


## Automatically generate terrains when the atlas is initialized.
func _atlas_autotiled(source_id: int, atlas: TileSetAtlasSource):
	var urm := EditorPlugin.new().get_undo_redo()
	urm.create_action("Create tiles in non-transparent texture regions", UndoRedo.MergeMode.MERGE_ALL, self, true)
	# NOTE: commit_action() is called immediately after.
	# NOTE: Atlas is guaranteed to have only been auto-generated with no extra peering bit information.
	TerrainPreset.write_default_preset(urm, tile_set, atlas)
	urm.commit_action()


## Keeps track of use_parent_material to see when it turns on or off.
var _cached_use_parent_material = null
##[br] Makes the main world grid invisible.
##[br] The main tiles don't need to be seen. Only the DisplayLayers should be visible.
##[br] Called every frame, and functions a lot like TileSetWatcher.
func _make_self_invisible() -> void:
	# If user has set a material in the original slot, inform the user
	if material != _ghost_material:
		if Engine.is_editor_hint():
			TileMapDualEditorPlugin.popup(
				"Warning! Direct material edit detected.",
				"Don't manually edit the real material in the editor! Instead edit the custom 'Display Material' property.\n" +
				"(Resetting the material to an invisible shader material... this is to keep the 'World Layer' invisible)\n" +
				"* This warning is only given when the material is set in the Godot editor.\n" +
				"* In-game scripts may set the material directly. It will be copied over to display_material automatically."
			)
		else:
			# copy over the material if it was edited by script
			display_material = material
		material = _ghost_material # Force TileMapDual's material to become invisible
	
	# check if use_parent_material is set
	if (
		Engine.is_editor_hint()
		and use_parent_material != _cached_use_parent_material
		and _cached_use_parent_material == false # cache may be null
	):
		TileMapDualEditorPlugin.popup(
			"Warning: Using Parent Material.",
			"The parent material will override any other materials used by the TileMapDual,\n" +
			"including the 'ghost shader' that the world tiles use to hide themselves.\n" +
			"This will cause the world tiles to show themselves in-game.\n" +
			"\n" +
			"* Recommendation: Turn this setting off. Don't use parent material.\n" +
			"* Workaround: Set your world tiles to custom sprites that are entirely transparent.\n" +
			"(see 'res://addons/TileMapDual/docs/custom_drawing_sprites.mp4' for a non-transparent example)"
		)
	_cached_use_parent_material = use_parent_material


## HACK: How long to wait before processing another "frame"
@export_range(0.0, 0.1) var refresh_time: float = 0.02
var _timer: float = 0.0
func _process(delta: float) -> void: # Only used inside the editor
	if refresh_time < 0.0:
		return
	if _timer > 0:
		_timer -= delta
		return
	_timer = refresh_time
	call_deferred('_changed')


## Called by signals when the tileset changes,
## or by _process inside the editor.
func _changed() -> void:
	_tileset_watcher.update(tile_set)
	_display.update([])
	_make_self_invisible()


## Called when the user draws on the map or presses undo/redo.
func _update_cells(coords: Array[Vector2i], forced_cleanup: bool) -> void:
	if is_instance_valid(_display):
		_display.update(coords)


##[br] Public method to add and remove tiles.
##[br]
##[br] - 'cell' is a vector with the cell position.
##[br] - 'terrain' is which terrain type to draw.
##[br] - terrain -1 completely removes the tile,
##[br] - and by default, terrain 0 is the empty tile.
func draw_cell(cell: Vector2i, terrain: int = 1) -> void:
	var terrains := _display.terrain.terrains
	if terrain not in terrains:
		erase_cell(cell)
		changed.emit()
		return
	var tile_to_use: Dictionary = terrains[terrain]
	var sid: int = tile_to_use.sid
	var tile: Vector2i = tile_to_use.tile
	set_cell(cell, sid, tile)
	changed.emit()

## Public method to get the terrain at a specific coordinate.
func get_cell(cell: Vector2i) -> int:
	return get_cell_tile_data(cell).terrain
