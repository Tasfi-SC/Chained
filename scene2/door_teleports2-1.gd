extends Area2D

func _ready() -> void:
	monitoring = false 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scene2/zone_confessionals.tscn")
