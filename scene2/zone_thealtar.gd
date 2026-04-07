extends Node2D

func _ready():
	var tween = create_tween()
	tween.tween_property(MusicManagerScene2.player, "volume_db", -80.0, 2.0)
	await tween.finished
	MusicManagerScene2.stop_music()
	MusicManagerSerath.play_music("res://scene2/2-05. Living With Determination (P3R ver.).mp3")
