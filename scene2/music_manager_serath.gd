extends Node

@onready var player = $AudioStreamPlayer

func _ready():
	player.stream = preload("res://scene2/2-05. Living With Determination (P3R ver.).mp3")
	player.volume_db = 0.0
	player.play()
