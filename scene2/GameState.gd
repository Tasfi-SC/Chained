extends Node

signal all_crystals_collected
signal crystal_count_changed(count: int)

var crystals_collected: int = 0
var all_crystals: bool = false

func collect_crystal() -> void:
	crystals_collected += 1
	emit_signal("crystal_count_changed", crystals_collected)
	if crystals_collected >= 4:
		all_crystals = true
		print("all got")
		emit_signal("all_crystals_collected")
