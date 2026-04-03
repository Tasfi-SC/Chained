extends Node2D

@export var next_scene_path: String = ""
@export var player_start_pos: Vector2 = Vector2.ZERO
@export var starts_locked: bool = false

@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_collision: CollisionShape2D = $TriggerArea/CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_unlocked: bool = true

func _ready() -> void:
	trigger_area.body_entered.connect(_on_body_entered)

	if anim.sprite_frames.has_animation("run"):
		anim.play("run")

	if starts_locked:
		is_unlocked = false
		visible = false
		trigger_collision.disabled = true
	else:
		is_unlocked = true
		visible = true
		trigger_collision.disabled = false

func unlock_portal() -> void:
	is_unlocked = true
	visible = true
	trigger_collision.disabled = false
	print("Portal unlocked!")

	if anim.sprite_frames.has_animation("run") and anim.animation != "run":
		anim.play("run")

func _on_body_entered(body: Node2D) -> void:
	print("Portal hit by:", body.name)

	if not is_unlocked:
		return

	if body.is_in_group("player"):
		print("Changing to:", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)
