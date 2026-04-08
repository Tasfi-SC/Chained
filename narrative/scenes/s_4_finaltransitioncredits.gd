extends Node2D

@onready var label = $resizefix/BLACKSCREENUI/RichTextLabel
const FULL_TEXT = "[center][font_size=25]CREDITS[/font_size]\n
	\nDEVELOPERS:
	\nVALERIA GABRIELA PALOMINO PAREDES\n
	\nTASKINA HASIN PROVA\n
	\nTASFI SAMAD CHOUDHURY\n
	\nNAZ KARAMAN\n
	\nART: MOSTLY AI GENERATED\n
	\nMUSIC: NETSUJOU NO SPECTRUM\n
	\nNOJUSUMA ON THE COLD FLOOR\n
	\nLIVING WITH DETERMINATION - P3R\n
	\nMEMORIES OF THE SCHOOL - PR3\n
	\nSCRIPT: TASFI SAMAD CHOUDHURY\n
	\nHUD: TASKINA HASIN PROVA\n
	\nNARRATION: TASFI SAMAD CHOUDHURY\n
	\nVALERIA GABRIELA PALOMINO PAREDES\n
	\nTASKINA HASIN PROVA[/center]"

var is_typing = false

func _ready():
	MusicManagerScene2.player.stop()
	MusicManagerSerath.player.stop()
	label.scroll_following = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = FULL_TEXT
	label.visible_characters = 0
	await get_tree().create_timer(0.2).timeout
	start_typing()

func start_typing():
	is_typing = true
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", len(label.get_parsed_text()),20)
	await tween.finished
	is_typing = false

func _input(event):
	if event.is_action_pressed("next_line"):
		if is_typing:
			label.visible_characters = -1
			is_typing = false
		else:
			get_tree().quit()
