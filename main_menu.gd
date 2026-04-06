extends Control
@onready var anim = $Node2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://narrative/scenes/STARTGAMEDIALOGUE.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
