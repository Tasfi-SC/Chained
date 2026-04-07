extends CharacterBody2D

const speed = 100
var dir : Vector2

func _physics_process(delta: float) -> void:
	velocity = dir * speed
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	dir = dir.normalized()
