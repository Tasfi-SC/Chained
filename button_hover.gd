extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	scale = Vector2(1.05, 1.05)

func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
