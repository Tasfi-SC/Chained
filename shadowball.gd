extends Area2D
var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var is_demon: bool = false
var damage: float = 15.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	if is_demon:
		damage = 25.0
		$AnimatedSprite2D.play("demon_ball")
	else:
		$AnimatedSprite2D.play("ball")

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
