extends CharacterBody2D

signal defeated

@export var speed: float = 80.0
@export var max_health: float = 70.0
@export var attack_damage: float = 25.0
@export var gravity: float = 900.0
@export var attack_cooldown: float = 1.0

var health: float
var is_dead: bool = false
var player: Node2D = null
var can_attack: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBarUI/ProgressBar

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	if anim.sprite_frames.has_animation("right"):
		anim.play("right")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	if player == null:
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				player = body

	if player:
		var dir_x = sign(player.global_position.x - global_position.x)

		
		anim.flip_h = dir_x > 0
		velocity.x = dir_x * speed

		if anim.animation != "right" and anim.sprite_frames.has_animation("right"):
			anim.play("right")
	else:
		velocity.x = 0

	move_and_slide()
	$HealthBarUI.scale.x = sign(scale.x) if scale.x != 0 else 1

func _on_detection_area_body_entered(body: Node2D) -> void:
	print(name, " detected: ", body.name)
	if body.is_in_group("player") and not is_dead:
		player = body
		print(name, " now following player")

func _on_detection_area_body_exited(body: Node2D) -> void:
	print(name, " lost: ", body.name)
	if body.is_in_group("player"):
		player = null

func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_dead or not can_attack:
		return

	if body.is_in_group("player"):
		body.take_damage(attack_damage)
		print("Shadowblob dealt ", attack_damage, " damage")
		can_attack = false
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_on_attack_area_body_entered(body)

func take_damage(amount: float) -> void:
	if is_dead:
		return

	health -= amount
	health_bar.value = max(health, 0)

	print(name, " took ", amount, " damage. HP left: ", health)

	if health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		attack_area.monitoring = false
		detection_area.monitoring = false
		health_bar.hide()

		if anim.sprite_frames.has_animation("death"):
			anim.play("death")
			print(name, " started death animation")
			await get_tree().create_timer(0.6).timeout

		print(name, " emitted defeated")
		defeated.emit()
		print(name, " queue_free now")
		queue_free()
