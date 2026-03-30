extends Area2D

@onready var black_rect: ColorRect = $"../CanvasLayer/ColorRect"

func _ready() -> void:
	input_pickable = true

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and GameState.all_crystals:
		await _fade_to_black()
		$"../DoorBroke".visible = false
		$"../DoorFix".visible = true
		await _fade_back()
		$"../TP".monitoring = true

func _fade_to_black() -> void:
	for i in range(100):
		black_rect.color.a += 0.01
		await get_tree().create_timer(0.01).timeout

func _fade_back() -> void:
	for i in range(100):
		black_rect.color.a -= 0.01
		await get_tree().create_timer(0.01).timeout
