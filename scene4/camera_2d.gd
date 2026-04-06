extends Camera2D

@export var target_path: NodePath
@export var follow_speed: float = 8.0
@export var fixed_y: float = -131.0  # Set this to your camera's current Y position

var target: Node2D

func _ready() -> void:
	
	target = get_node_or_null(target_path)
	enabled = true
	position_smoothing_enabled = false

func _process(delta: float) -> void:
	if not target:
		return

	var desired = Vector2(target.global_position.x, fixed_y)
	global_position = global_position.lerp(desired, follow_speed * delta)
