extends AudioStreamPlayer

# Define your timestamps in seconds
@export var start_time: float = 28  # Where the music should start/loop back to
@export var end_time: float = 52.0    # Where the music should "hit the wall" and restart

func _ready():
	# Start the music at your specific start point
	play(start_time)

func _process(_delta):
	# We check every frame if we've passed the end point
	if playing:
		var current_pos = get_playback_position()
		
		if current_pos >= end_time:
			# Loop back to the start_time
			seek(start_time)
