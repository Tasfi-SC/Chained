extends Node2D

@onready var character = $resizefix/Control/narrative_mc
@onready var speaker_label = $resizefix/Control/narrative_mc/speaker_name
@onready var dialog_text = $resizefix/Control/narrative_mc/DialogUI/RichTextLabel
@onready var character_sprite = $resizefix/Control/narrative_mc/Sprite2D
@onready var dialog_ui = $resizefix/Control/narrative_mc/DialogUI
const speaker_change = {
	"MC NAME": preload("res://narrative/resources/mctextbox.png"),
	"MALEFICA": preload("res://narrative/maleficatextbox.png")
}

const speaker_positions = {
	"MC NAME": Vector2(350, 550),
	"MALEFICA": Vector2(400, 750)
}

const speaker_scales = {
	"MC NAME": Vector2(.8, .8), 
	"MALEFICA": Vector2(1.1, 1.1)
}
var dialog_index : int = 0
const ui_base_position = Vector2(30, 430) 
const text_base_position = Vector2(180, 550)
const dialog_lines : Array[String] = [
	"MALEFICA: YES",
	"MC NAME: What is this. Why am I here. What did you do to me.",
	"MALEFICA: HELL IS FAILING, IT NEEDS AN ANCHOR.",
	"MALEFICA: A SOUL THAT HAS WALKED EVERY LAYER AND ABSORBED ITS POWER. A SOUL WITH HUMAN CONSCIOUSNESS SO IT STAYS AWARE. AWARE ENOUGH TO HOLD THE STRUCTURE.",
	"MC NAME: AND YOU BUILT THAT FOR ME?",
	"MALEFICA: ................",
	"MC NAME: LET ME GO.",
	"MALEFICA: I KNOW YOU WANT THAT CHILD",


	



]

func _ready():
	dialog_index = 0
	process_current_line()

	#dialog_ui.position = Vector2(200, 400)
	dialog_ui.size = Vector2(650, 100)
	
	speaker_label.position = Vector2(180, 685)
	speaker_label.size = Vector2(150, 30)

	#dialog_text.position = Vector2(200, 550)
	dialog_text.size = Vector2(650, 100)
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text.visible_characters = -1


	

func _input(event):
	if event.is_action_pressed("next_line"):
		if dialog_index < len(dialog_lines) -1:
			dialog_index +=1
			process_current_line()
		else:
			get_tree().change_scene_to_file("res://narrative/scenes/S4-FINALTRANSITION.tscn")

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
	dialog_ui.position = ui_base_position
	dialog_text.position = text_base_position
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
		
