extends CanvasLayer

@onready var icon_bar = $HBoxContainer

func _ready():
	# This ensures the script runs AFTER the node is inside the tree
	await get_tree().process_frame 
	get_viewport().size_changed.connect(update_ui_position)
	update_ui_position()

func update_ui_position():
	if not icon_bar: return
	
	var viewport_size = get_viewport().get_visible_rect().size
	

	var offset_x = 750
	var offset_y = 150
	
	icon_bar.position = Vector2(
		viewport_size.x - offset_x, 
		viewport_size.y - offset_y
	)
