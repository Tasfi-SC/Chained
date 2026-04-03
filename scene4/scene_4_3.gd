extends Node2D

@onready var portal = $Portal
@onready var redblob1 = $Redblob1
@onready var redblob2 = $Redblob2
@onready var redblob3 = $Redblob3

var redblobs_defeated: int = 0

func _ready() -> void:
	print("Scene4_3 ready")
	redblob1.defeated.connect(_on_redblob_defeated)
	redblob2.defeated.connect(_on_redblob_defeated)
	redblob3.defeated.connect(_on_redblob_defeated)

func _on_redblob_defeated() -> void:
	redblobs_defeated += 1
	print("Redblobs defeated: ", redblobs_defeated, "/3")

	if redblobs_defeated >= 3:
		print("Unlocking Scene4_3 portal")
		portal.unlock_portal()
