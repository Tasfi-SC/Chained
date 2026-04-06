extends Node2D

@onready var character = $resizefix/Control/narrative_mc
@onready var speaker_label = $resizefix/Control/narrative_mc/speaker_name
@onready var dialog_text = $resizefix/Control/narrative_mc/DialogUI/RichTextLabel
@onready var character_sprite = $resizefix/Control/narrative_mc/Sprite2D
@onready var dialog_ui = $resizefix/Control/narrative_mc/DialogUI
const speaker_change = {
	"MC NAME": preload("res://narrative/resources/mctextbox.png"),
	"VAEL": preload("res://narrative/vaeltextbox.png")
}
const speaker_positions = {
	"MC NAME": Vector2(642, 362),
	"VAEL": Vector2(600, 500)
}

const speaker_scales = {
	"MC NAME": Vector2(.8, .8), 
	"VAEL": Vector2(1, 1)
}
var dialog_index : int = 0

const dialog_lines : Array[String] = [
	"VAEL:The heir walks the deep floors. The chain is ready. The throne awaits its anchor.",
]

func _ready():
	dialog_index = 0
	process_current_line()
	dialog_text.position = Vector2(600,350)
	dialog_text.size = Vector2(400, 150)

	speaker_label.position = Vector2(500, 390)
	speaker_label.size = Vector2(150, 30)
	dialog_text.position = Vector2(235,490)
	dialog_text.size = Vector2(400, 150)


	dialog_ui.position = Vector2(320, 150)
	dialog_ui.size = Vector2(650, 100)

func _input(event):
	if event.is_action_pressed("next_line"):
		if dialog_index < len(dialog_lines) -1:
			dialog_index +=1
			process_current_line()
		else:
			get_tree().change_scene_to_file("res://scene4/Scene_4_4.tscn")

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info)>=2)
	return{
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}
func process_current_line():
	
	var line = dialog_lines[dialog_index]
	var line_info = parse_line(line)
	speaker_label.text = line_info["speaker_name"]
	dialog_text.text = line_info["dialog_line"]
	
	var speaker = line_info["speaker_name"].strip_edges()

	if speaker_change.has(speaker):
		character_sprite.texture = speaker_change[speaker]
		character_sprite.position = speaker_positions[speaker]
		character_sprite.scale = speaker_scales[speaker]
		
		# typing anim
		dialog_text.text = line_info["dialog_line"]
		dialog_text.visible_characters = 0
		var tween = create_tween()
		tween.tween_property(dialog_text, "visible_characters", len(line_info["dialog_line"]), 1.5)
		
