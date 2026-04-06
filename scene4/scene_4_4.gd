extends Node

@onready var vael = $vael
@export_file var next_scene = "res://scene4/narrative_4_2.tscn"

func _ready():
	MusicManagerScene2.player.stop()
	MusicManagerSerath.player.stop()
	if vael:
		vael.boss_died.connect(_on_vael_defeated)

func _on_vael_defeated():
	await get_tree().create_timer(2.3).timeout
	
	get_tree().change_scene_to_file(next_scene)
