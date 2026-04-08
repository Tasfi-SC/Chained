extends CanvasLayer 

func _ready():
	$Node2D/AnimatedSprite2D.play("default")
	show()
	layer = 100

func _on_resume_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene3/Scene3_2.tscn")

func _on_mainmenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
