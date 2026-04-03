extends Node2D

@onready var portal = $Portal
@onready var shadowblob1 = $Shadowblob1
@onready var shadowblob2 = $Shadowblob2
@onready var shadowblob3 = $Shadowblob3

var blobs_defeated: int = 0

func _ready() -> void:
	shadowblob1.defeated.connect(_on_blob_defeated)
	shadowblob2.defeated.connect(_on_blob_defeated)
	shadowblob3.defeated.connect(_on_blob_defeated)

func _on_blob_defeated() -> void:
	blobs_defeated += 1
	print("Blobs defeated: ", blobs_defeated, "/3")

	if blobs_defeated >= 3:
		print("Unlocking portal now")
		portal.unlock_portal()
