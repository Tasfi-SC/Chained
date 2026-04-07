extends Node2D

@onready var speaker_label = $resizefix/Control/narrative_mc/speaker_name
@onready var dialog_ui = $resizefix/Control/narrative_mc/DialogUI/RichTextLabel
@onready var character = $resizefix/Control/narrative_mc
@onready var character_sprite = $resizefix/Control/narrative_mc/Sprite2D
@onready var player = $"../Player"

const speaker_change = {
	"SERATH": preload("res://narrative/resources/serathtextbox.png")
}
const speaker_positions = {
	"SERATH": Vector2(300, 760)
}
const speaker_scales = {
	"SERATH": Vector2(1, 1)
}

const serath_dialog: Array[String] = [
	"SERATH: She loves you.",
	"SERATH: That's the cruelest part."
]

var current_dialog: Array[String] = []
var dialog_index: int = 0

func _ready() -> void:
	character.visible = false
	get_node("../Serath").serath_died.connect(_on_serath_died)

func _on_serath_died() -> void:
	player.can_move = false
	current_dialog = serath_dialog
	dialog_index = 0
	character.visible = true
	process_current_line()

func _input(event):
	if not character.visible:
		return
	if event.is_action_pressed("next_line"):
		if dialog_index < len(current_dialog) - 1:
			dialog_index += 1
			process_current_line()
		else:
			character.visible = false
			player.can_move= true 

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

func process_current_line():
	var line = current_dialog[dialog_index]
	var line_info = parse_line(line)
	speaker_label.text = line_info["speaker_name"]
	
	var speaker = line_info["speaker_name"].strip_edges()
	if speaker_change.has(speaker):
		character_sprite.texture = speaker_change[speaker]
		character_sprite.position = speaker_positions[speaker]
		character_sprite.scale = speaker_scales[speaker]

	dialog_ui.text = line_info["dialog_line"]
	dialog_ui.visible_characters = 0
	var tween = create_tween()
	tween.tween_property(dialog_ui, "visible_characters", len(line_info["dialog_line"]), 1.5)
