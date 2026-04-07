extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: float = 250.0
@export var attack_cooldown: float = 5.0
@export var gravity: float = 900.0

enum State { IDLE, CHASE, SLAM, SWEEP, SUMMON, DEATH }

var health: float
var current_state: State = State.IDLE
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var attack_queue: Array = ["slam", "sweep", "summon"]
var attack_index: int = 0

@onready var health_bar: ProgressBar = $HealthBarUI/ProgressBar
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var shockwave_area: Area2D = $ShockwaveArea

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true

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
				if anim.animation != "walk":
					anim.play("walk")
			else:
				_set_state(State.IDLE)
		State.SLAM, State.SWEEP, State.SUMMON:
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
				anim.play("walk")
		State.CHASE:
			_face_player()
			anim.play("walk")
		State.SLAM:
			_face_player()
			anim.play("slam")
		State.SWEEP:
			_face_player()
			anim.play("sweep")
		State.SUMMON:
			_face_player()
			anim.play("summon")
		State.DEATH:
			anim.play("dead")
			is_dead = true
			health_bar.hide()
			

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		player = body
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

	if current_state == State.SLAM or current_state == State.SWEEP:
		_deal_percent_damage(body)
	elif can_attack:
		_trigger_next_attack()

func _on_shockwave_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.SUMMON and not is_dead:
		_deal_percent_damage(body)

func _trigger_next_attack() -> void:
	if not can_attack or is_dead:
		return
	can_attack = false

	var next_attack = attack_queue[attack_index]
	attack_index = (attack_index + 1) % attack_queue.size()

	match next_attack:
		"slam":
			_set_state(State.SLAM)
		"sweep":
			_set_state(State.SWEEP)
		"summon":
			_set_state(State.SUMMON)

func _deal_percent_damage(body: Node2D) -> void:
	var damage = body.health * 0.5
	body.take_damage(damage)
	print("Gorth dealt: ", damage, " to ", body.name)

func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.SLAM, State.SWEEP:
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_deal_percent_damage(body)
					break
			attack_timer.start()
			_set_state(State.IDLE)
		State.SUMMON:
			for body in shockwave_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_deal_percent_damage(body)
					break
			attack_timer.start()
			_set_state(State.IDLE)
		State.DEATH:
			anim.stop()
			get_tree().call_group("portals", "unlock_portal")
			await get_tree().create_timer(0.5).timeout
			queue_free()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if player and not is_dead:
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				_trigger_next_attack()
				break

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	health_bar.value = health
	if health <= 0:
		health_bar.value = 0
		_set_state(State.DEATH)
