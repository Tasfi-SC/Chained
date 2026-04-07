extends Area2D
var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var is_demon: bool = false
var damage: float = 15.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	print("Ball spawned. Layer: ", collision_layer, " Mask: ", collision_mask)
	if is_demon:
		damage = 25.0
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("default")
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	print("Ball touched: ", body.name, " | groups: ", body.get_groups())
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
