extends Camera2D

@export var target_path: NodePath
@export var follow_speed: float = 8.0
@export var fixed_y: float = -131.0 

var target: Node2D
const MAP_LEFT = -2985.0
const MAP_RIGHT = -803.0
const HALF_WIDTH = 800.0
func _ready() -> void:
	target = get_node_or_null(target_path)
	enabled = true
	position_smoothing_enabled = false

func _process(delta: float) -> void:
	if not target:
		return

	var desired_x = target.global_position.x

	desired_x = clamp(desired_x, MAP_LEFT + HALF_WIDTH, MAP_RIGHT - HALF_WIDTH)

	var desired = Vector2(desired_x, fixed_y)
	global_position = global_position.lerp(desired, follow_speed * delta)	
	global_position = global_position.lerp(desired, follow_speed * delta)
