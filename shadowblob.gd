extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 70.0
@export var attack_damage: float = 15.0
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
	anim.animation_finished.connect(_on_animation_finished)
	
	anim.play("right")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta

	if player:
		# Face player
		var dir_x = sign(player.global_position.x - global_position.x)
		anim.flip_h = dir_x < 0
		
		# Move toward player
		velocity.x = dir_x * speed
		anim.play("right")
	else:
		velocity.x = 0

	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
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

func _on_animation_finished() -> void:
	if anim.animation == "death":
		queue_free()

func take_damage(amount: float) -> void:
	if is_dead:
		return
		
	health -= amount
	health_bar.value = health
	
	print("Shadowblob took ", amount, " damage. HP left: ", health)
	
	if health <= 0:
		health_bar.value = 0
		is_dead = true
		anim.play("death")
