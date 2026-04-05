extends Node2D

func _ready():
	var tween = create_tween()
	tween.tween_property(MusicManagerScene2.player, "volume_db", -80.0, 4.0)
	await tween.finished
	MusicManagerScene2.player.stop()
	MusicManagerSerath.player.play()
