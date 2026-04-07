extends CanvasLayer

@onready var box = $Control/narrative_mc
@onready var speaker_label = $Control/narrative_mc/speaker_name
@onready var dialog_ui = $Control/narrative_mc/DialogUI
@onready var dialog_text = $Control/narrative_mc/DialogUI/RichTextLabel
@onready var player = $"../Player"
@onready var character_sprite = $Control/narrative_mc/Sprite2D

const speaker_change = {
	"MC NAME": preload("res://narrative/resources/mctextbox.png"),
	"REDBLOB": preload("res://narrative/redblobtextbox.png")
}
const dialog_lines = [
	"REDBLOB: [color=red]RAWRR.[/color]",
	"MC NAME: ..."
]

var dialog_index := 0
var active := false

func _ready():
	box.visible = false

	box.position = Vector2(200, 100)
	#character_sprite.position = Vector2(600, 610)
	#dialog_ui.position = Vector2(235,490)
	#dialog_ui.size = Vector2(400, 150)

	#speaker_label.position = Vector2(385, 760)
	#speaker_label.size = Vector2(150, 30)

	#dialog_text.position = Vector2(350, 550)
	#dialog_text.size = Vector2(650, 100)
	#dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#dialog_text.visible_characters = -1

func start_dialog():
	active = true
	dialog_index = 0
	box.visible = true
	player.set_physics_process(false)
	player.set_process_input(false)
	show_line()

func show_line():
	var line = dialog_lines[dialog_index]
	var split_index = line.find(":")
	if split_index == -1:
		return
	var speaker_name = line.substr(0, split_index).strip_edges()
	speaker_label.text = speaker_name
	dialog_text.text = line.substr(split_index + 1).strip_edges()
	dialog_text.visible_characters = -1
	if speaker_change.has(speaker_name):
		character_sprite.texture = speaker_change[speaker_name]
func end_dialog():
	active = false
	box.visible = false
	player.set_physics_process(true)
	player.set_process_input(true)

func _unhandled_input(event):
	if not active:
		return

	if event.is_action_pressed("next_line"):
		dialog_index += 1
		if dialog_index >= dialog_lines.size():
			end_dialog()
			return
		show_line()
