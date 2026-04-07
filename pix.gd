extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 100.0
@export var attack_cooldown: float = 2.0
@export var gravity: float = 900.0

enum State { IDLE, CHASE, DOUBLE_HIT, ENERGY_PULSE, DUPLICATE, DEATH }

var health: float
var current_state: State = State.IDLE
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var attack_queue: Array = ["double_hit", "energy_pulse", "duplicate"]
var attack_index: int = 0

@onready var health_bar: ProgressBar = $HealthBarUI/ProgressBar
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var pulse_area: Area2D = $PulseArea

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
	pulse_area.body_entered.connect(_on_pulse_area_body_entered)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	_set_state(State.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.IDLE:
			velocity.x = 0
		State.CHASE:
			if player:
				var dir_x = sign(player.global_position.x - global_position.x)
				velocity.x = dir_x * speed
				anim.flip_h = dir_x < 0
				if anim.animation != "right":
					anim.play("right")
			else:
				_set_state(State.IDLE)
		State.DOUBLE_HIT, State.ENERGY_PULSE, State.DUPLICATE:
			velocity.x = 0
		State.DEATH:
			velocity = Vector2.ZERO

	move_and_slide()
	$HealthBarUI.scale.x = sign(scale.x) if scale.x != 0 else 1

func _face_player() -> void:
	if player:
		anim.flip_h = player.global_position.x < global_position.x

func _set_state(new_state: State) -> void:
	current_state = new_state

	match new_state:
		State.IDLE:
			if anim.sprite_frames.has_animation("idle"):
				anim.play("idle")
			else:
				anim.play("right")
		State.CHASE:
			anim.play("right")
			_face_player()
		State.DOUBLE_HIT:
			_face_player()
			anim.play("double_hit")
		State.ENERGY_PULSE:
			_face_player()
			anim.play("energy_pulse")
		State.DUPLICATE:
			_face_player()
			anim.play("duplicate")
		State.DEATH:
			anim.play("death")
			is_dead = true
			health_bar.hide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		player = body
		if current_state == State.IDLE:
			_set_state(State.CHASE)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		can_attack = true
		attack_timer.stop()
		_set_state(State.IDLE)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_dead:
		return

	if current_state == State.DOUBLE_HIT or current_state == State.DUPLICATE:
		_deal_percent_damage(body)
	elif can_attack:
		_trigger_next_attack()

func _on_pulse_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.ENERGY_PULSE and not is_dead:
		_deal_percent_damage(body)

func _trigger_next_attack() -> void:
	if not can_attack or is_dead:
		return
	can_attack = false

	var next_attack = attack_queue[attack_index]
	attack_index = (attack_index + 1) % attack_queue.size()

	match next_attack:
		"double_hit":
			_set_state(State.DOUBLE_HIT)
		"energy_pulse":
			_set_state(State.ENERGY_PULSE)
		"duplicate":
			_set_state(State.DUPLICATE)

func _deal_percent_damage(body: Node2D) -> void:
	var damage = body.max_health * 0.25
	body.take_damage(damage)
	print("Pix dealt: ", damage, " to ", body.name)

func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.DOUBLE_HIT, State.DUPLICATE:
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_deal_percent_damage(body)
					break
			attack_timer.start()
			_set_state(State.IDLE)
		State.ENERGY_PULSE:
			for body in pulse_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_deal_percent_damage(body)
					break
			attack_timer.start()
			if player:
				_set_state(State.CHASE)
			else:
				_set_state(State.IDLE)
		State.DEATH:
			anim.stop()
			queue_free()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if player and not is_dead:
		_trigger_next_attack()

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	health_bar.value = health
	if health <= 0:
		health_bar.value = 0
		_set_state(State.DEATH)
