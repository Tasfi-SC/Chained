extends Node2D

func _ready():
	var tween = create_tween()
	tween.tween_property(MusicManagerScene2.player, "volume_db",  -25, 2.0)
