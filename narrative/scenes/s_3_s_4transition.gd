extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel

const FULL_TEXT = "[center]THE VOICE IS GONE.\n\nFOR THE FIRST TIME SINCE HE FELL, MC CANT HEAR HER.\n\nTHE SINCE IS WORSE.[/center]"

var is_typing = false

func _ready():
	label.text = FULL_TEXT
	label.visible_characters = 0
	await get_tree().create_timer(0.2).timeout
	start_typing()

func start_typing():
	is_typing = true
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", len(label.get_parsed_text()), 7.0)
	await tween.finished
	is_typing = false

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		else:
			get_tree().change_scene_to_file("res://scene4/Scene4_1.tscn")
