extends AudioStreamPlayer


@export var start_time: float = 80
@export var end_time: float = 83

func _ready():
	MusicManagerScene2.player.stop()
	MusicManagerSerath.player.stop()
	play(start_time)

func _process(_delta):

	if playing:
		var current_pos = get_playback_position()
		
		if current_pos >= end_time:
			
			seek(start_time)
