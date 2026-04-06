extends AudioStreamPlayer

# Define your timestamps in seconds
@export var start_time: float = 0  # Where the music should start/loop back to
@export var end_time: float = 202.0    

func _ready():
	MusicManagerScene2.player.stop()
	MusicManagerSerath.player.stop()
	play(start_time)

func _process(_delta):
	if playing:
		var current_pos = get_playback_position()
		
		if current_pos >= end_time:
			# Loop back to the start_time
			seek(start_time)
