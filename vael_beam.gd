extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0
var damage: float = 35.0

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not $VisibleOnScreenNotifier2D.screen_exited.is_connected(queue_free):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

	if $AnimatedSprite2D.sprite_frames.has_animation("beamprojectile"):
		$AnimatedSprite2D.play("beamprojectile")

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
