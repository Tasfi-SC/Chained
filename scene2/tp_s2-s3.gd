extends Node2D

var has_played: bool = false
var player: Node2D = null
var anim: AnimatedSprite2D = null

func _ready() -> void:
	anim = get_node("tpsprite")
	print("anim found: ", anim)
	anim.stop()
	anim.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	print("player found: ", player)

func _process(_delta: float) -> void:
	if has_played or player == null:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < 80:
		has_played = true
		anim.play("tprun")

func _on_animation_finished() -> void:
	if anim.animation == "tprun":
		get_tree().change_scene_to_file("res://scene3/Scene3_1.tscn")
