extends Area2D
@export var dialogue_layer_path: NodePath
var triggered := false
@onready var player = $"../Player"


func _on_body_entered(body: Node2D) -> void:
	print("Something entered: ", body.name)

	if triggered:
		return

	if body.is_in_group("player"):
		print("Player detected")
		triggered = true

		var dialogue_layer = get_node("../DialogueLayer")
		print("Dialogue layer found: ", dialogue_layer.name)
		player.can_move = false
		player.velocity = Vector2.ZERO
		player._play_anim("idle")
		dialogue_layer.start_dialog()
		print("start_dialog called")
		player.can_move = true
