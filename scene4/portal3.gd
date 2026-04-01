extends Node2D
@export var next_scene_path: String = ""
@export var player_start_pos: Vector2 = Vector2.ZERO

@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Portal hit by:", body.name)  
	if body.is_in_group("player"):
			print("Changing to:", next_scene_path)
			get_tree().change_scene_to_file(next_scene_path)
