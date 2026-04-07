extends CanvasLayer 
var current_level_path: String
func _ready():
	$Node2D/AnimatedSprite2D.play("default")
	show()
	layer = 100

func _on_resume_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(current_level_path)

func _on_mainmenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
