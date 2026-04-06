extends CanvasLayer

@onready var box = $narrative_mc
@onready var speaker_label = $narrative_mc/speaker_name
@onready var dialog_ui = $narrative_mc/DialogUI
@onready var dialog_text = $narrative_mc/DialogUI/RichTextLabel
@onready var player = $"../Player"
@onready var character_sprite = $narrative_mc/Sprite2D

const dialog_lines = [
	"MC NAME: What is this place, somehow feels familiar."
]

var dialog_index := 0
var active := false

func _ready():
	box.visible = false

	box.position = Vector2(0, 0)
	character_sprite.position = Vector2(600, 610)

	dialog_ui.position = Vector2(235,490)
	dialog_ui.size = Vector2(400, 150)

	speaker_label.position = Vector2(385, 760)
	speaker_label.size = Vector2(150, 30)

	dialog_text.position = Vector2(350, 550)
	dialog_text.size = Vector2(550, 80)
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_text.visible_characters = -1

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

	speaker_label.text = line.substr(0, split_index).strip_edges()
	dialog_text.text = line.substr(split_index + 1).strip_edges()
	dialog_text.visible_characters = -1

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
