extends Area2D
signal slow_trig
var triggered = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not triggered:
		triggered = true
		emit_signal("slow_trig")	
