extends Node

signal all_crystals_collected

var crystals_collected: int = 0
var all_crystals: bool = false

func collect_crystal() -> void:
	crystals_collected += 1
	if crystals_collected >= 4:
		all_crystals = true
		print("all got")
		emit_signal("all_crystals_collected")
