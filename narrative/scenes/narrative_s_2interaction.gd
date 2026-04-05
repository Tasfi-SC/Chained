extends Node2D

@onready var speaker_label = $resizefix/Control/narrative_mc/speaker_name
@onready var dialog_ui = $resizefix/Control/narrative_mc/DialogUI/RichTextLabel
@onready var character = $resizefix/Control/narrative_mc
@onready var character_sprite = $resizefix/Control/narrative_mc/Sprite2D

const speaker_change = {
	"MC NAME": preload("res://narrative/resources/mctextbox.png"),
	"UNKNOWN": preload("res://narrative/resources/textbox.png")
}
const speaker_positions = {
	"MC NAME": Vector2(642, 362),
	"UNKNOWN": Vector2(642, 362)
}
const speaker_scales = {
	"MC NAME": Vector2(0.8, 0.8),
	"UNKNOWN": Vector2(0.8, 0.8)
}

const crystals_dialog: Array[String] = [
	"MC NAME: ...that's all of them.",
	"MC NAME: ...why does this feel familiar?",
	"UNKNOWN: Keep going.",
	"UNKNOWN: You're close.",
	"MC NAME: ...close to what?"
]
const door_dialog: Array[String] = [
	"UNKNOWN: Open it.",
	"MC NAME: ...you've been guiding me this whole time.",
	"MC NAME: Why?",
	"UNKNOWN: You were meant to be here."
]
const serath_dialog: Array[String] = [
	"UNKNOWN: She loves you. That's the cruelest part."
]

var current_dialog: Array[String] = []
var dialog_index: int = 0

func _ready() -> void:
	character.visible = false
	GameState.all_crystals_collected.connect(_on_all_crystals_collected)
	get_node("../Door").door_interacted.connect(_on_door_interacted)
	
func _on_all_crystals_collected() -> void:
	current_dialog = crystals_dialog
	dialog_index = 0
	character.visible = true
	process_current_line()

func _on_door_interacted() -> void:
	current_dialog = door_dialog
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
