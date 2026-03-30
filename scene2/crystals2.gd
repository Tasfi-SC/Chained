extends Area2D

var collected: bool = false

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player") and not collected:
		collected = true
		$"../Crystals2".visible  = false
		GameState.collect_crystal()
		$"../CrystalLabel2".visible = true
		await get_tree().create_timer(1.0).timeout
		$"../CrystalLabel2".visible = false
