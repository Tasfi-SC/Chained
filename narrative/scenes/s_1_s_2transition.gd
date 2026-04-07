extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel
@onready var type_sound: AudioStreamPlayer = $TypeSound

const FULL_TEXT = "[center]MC STARES AT HIS HANDS.\n\nHE DOESN'T FEEL VICTORIOUS. HE FEELS WRONG.\n\nHE KEEPS MOVING. THERE'S NOTHING ELSE TO DO.[/center]"

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
	tween.tween_callback(func(): is_typing = false)
	
	while is_typing:
		type_sound.play()
		await get_tree().create_timer(0.1).timeout

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		else:
			get_tree().change_scene_to_file("res://narrative/scenes/narratives_2_1.tscn")
