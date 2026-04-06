extends CanvasLayer

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.crystal_count_changed.connect(_on_crystals_count_changed)
	label.text = "Crystals: 0/4"

func _on_crystals_count_changed(count: int):
	label.text = "Crystals: %d/4" % count
