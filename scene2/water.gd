extends Area2D
func _on_body_entered(body):
	# print("entered wattter")
	print(body.get_groups())
	if body.is_in_group("player"):
		# print("WATERRR")
		body.in_water = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.in_water = false
