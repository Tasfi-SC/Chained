extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel

const FULL_TEXT = "[center]MALEFICA RAISES HER HAND.\n\nCHAINS RISE FROM THE FLOOR, WRAPPING AROUND MC's WRIST,ANKLES, THROAT.
\n\nTHEY PULL HIM DOWNWARD SLOWLY UNTIL HE IS ON HIS KNEES, HANDS BOUND BEHIND HIM, A CHAIN RUNNING FROM HIS COLLAR TO HER HAND LIKE A LEASH.\n\n
HE STRAINS AGAINST THE CHAINS. THEY DON'T MOVE. HE STOPS.MALEFICA LOOKS DOWN AT HIM. HER EXPRESSION DOES NOT CHANGE. SHE REACHES DOWN AND TOUCHES HIS HAIR ONCE\n\n
TURNS AND WALKS TOWARD A DOOR AT THE FAR END OF THE ROOM. IT OPENS ONTO PALE GREY LIGHT. THE HUMAN WORLD.
SHE STEPS THROUGH. THE DOOR CLOSES.
[/center]"

var is_typing = false

func _ready():
	label.scroll_following = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = FULL_TEXT
	label.visible_characters = 0
	await get_tree().create_timer(0.2).timeout
	start_typing()

func start_typing():
	is_typing = true
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", len(label.get_parsed_text()),70)
	await tween.finished
	is_typing = false

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		else:
			get_tree().change_scene_to_file("res://scene4/Scene4_1.tscn")
