extends CanvasLayer 

func _ready():
	$Node2D/AnimatedSprite2D.play("default")
	hide()
	
func _unhandled_input(event):

	if get_tree().current_scene.name == "MainMenu": 
		return
		
	if event.is_action_pressed("pause"):
		toggle_pause()
		$"../AbilityHUD".hide()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	
	if visible:

		offset = Vector2.ZERO 
	
	print("Game Paused: ", get_tree().paused)

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_mainmenu_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://main_menu.tscn")
