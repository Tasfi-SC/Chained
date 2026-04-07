extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel

const TEXT_PARTS : Array[String] = [
	"[center]Malefica raises her hand.\n\nChains rise from the floor, wrapping around MC's wrist, ankles, throat.[/center]",
	"[center]They pull him downward slowly until he is on his knees, a chain running from his collar to her hand like a leash.[/center]",
	"[center]Malefica looks down at him. Her expression does not change. She reaches down and touches his hair once.[/center]",
	"[center]And walks towards the door at the far end of the room. It opens onto pale grey light. The human world.\n\nShe steps through.[/center]"
]

var part_index : int = 0
var is_typing : bool = false

func _ready():
	label.scroll_following = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	await get_tree().create_timer(0.2).timeout
	show_current_part()

func show_current_part():
	label.text = TEXT_PARTS[part_index]
	label.visible_characters = 0
	is_typing = true
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", len(label.get_parsed_text()), 10)
	await tween.finished
	is_typing = false

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		elif part_index < len(TEXT_PARTS) - 1:
			part_index += 1
			show_current_part()
		else:
			get_tree().change_scene_to_file("res://narrative/scenes/S4-FINALTRANSITION2.tscn")
