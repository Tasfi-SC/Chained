extends AudioStreamPlayer


@export var start_time: float = 2.5  
@export var end_time: float = 15.0    

func _ready():
	
	play(start_time)

func _process(_delta):
	
	if playing:
		var current_pos = get_playback_position()
		
		if current_pos >= end_time:
			
			seek(start_time)
