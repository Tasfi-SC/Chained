extends Node

@onready var player = $AudioStreamPlayer

var curr_track = null
var music_volume = -16.0

func play_music(path):
	if curr_track == path:
		return
	curr_track = path
	player.stream = load(path)
	player.volume_db = music_volume
	player.play()
func stop_music():
	player.stop()
	curr_track = null
