extends StaticBody2D

@export var hits_required: int = 3
var current_hits: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_detector: Area2D = $hitdetect
@onready var collision: CollisionShape2D = $CollisionShape2D

func _on_hitdetect_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		take_hit()
		
func take_hit():
	current_hits += 1
	
	sprite.modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if current_hits >= hits_required:
		_break()

func _break():
	collision.disabled = true
	visible = false
