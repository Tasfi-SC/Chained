extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel

const FULL_TEXT = "[center]You're closer.\n\nAccept it.[/center]"

var is_typing = false

func _ready():
	label.text = FULL_TEXT
	label.visible_characters = 0
	await get_tree().create_timer(0.2).timeout
	start_typing()

func start_typing():
	is_typing = true
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", len(label.get_parsed_text()), 5.0)
	await tween.finished
	is_typing = false

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		else:
			get_tree().change_scene_to_file("res://scene2/zone_nave.tscn")
