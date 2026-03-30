extends CharacterBody2D
@export var speed: float = 80.0
@export var health: float = 500.0
@export var attack_cooldown: float = 2.0

enum State { IDLE, LEFT, RIGHT, DASH, EVIL_EYE, SHADOWBALL, DEATH }
var current_state: State = State.IDLE
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var phase_timer: Timer = $PhaseTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var evileye_area: Area2D = $EvileyeArea

var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var attack_landed: bool = false
var attack_queue: Array = ["dash", "evil_eye", "shadowball"]
var attack_index: int = 0

func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	evileye_area.body_entered.connect(_on_evileye_area_body_entered)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	_set_state(State.IDLE)

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.LEFT, State.RIGHT:
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				if direction.x < 0:
					anim.play("left")
					current_state = State.LEFT
				else:
					anim.play("right")
					current_state = State.RIGHT
			else:
				_set_state(State.IDLE)
		State.DASH, State.EVIL_EYE, State.SHADOWBALL:
			velocity = Vector2.ZERO
	move_and_slide()
func _set_state(new_state: State) -> void:
	current_state = new_state
	attack_landed = false
	match new_state:
		State.IDLE:      anim.play("idle")
		State.LEFT:      anim.play("left")
		State.RIGHT:     anim.play("right")
		State.DASH:      anim.play("dash")
		State.EVIL_EYE:  anim.play("evil_eye")
		State.SHADOWBALL: anim.play("shadowball")
		State.DEATH:
			anim.play("death")
			is_dead = true
func _on_evileye_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.EVIL_EYE and not is_dead:
		_deal_percent_damage(body)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_dead:
		return
	if current_state == State.DASH or current_state == State.SHADOWBALL:
		_deal_percent_damage(body)
	elif can_attack:
		_trigger_next_attack()
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		player = body
		# Pick walk direction based on player position
		if player.global_position.x < global_position.x:
			_set_state(State.LEFT)
		else:
			_set_state(State.RIGHT)

func _trigger_next_attack() -> void:
	if not can_attack or is_dead:
		return
	can_attack = false
	attack_landed = false
	var next_attack = attack_queue[attack_index]
	attack_index = (attack_index + 1) % attack_queue.size()
	match next_attack:
		"dash":       _set_state(State.DASH)
		"evil_eye":   _set_state(State.EVIL_EYE)
		"shadowball": _set_state(State.SHADOWBALL)
func _deal_percent_damage(body: Node2D) -> void:
	if attack_landed:
		return
	attack_landed = true
	var damage = body.health * 0.25
	body.take_damage(damage)
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		can_attack = true
		attack_landed = false
		attack_timer.stop()
		_set_state(State.IDLE)

func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.DASH, State.EVIL_EYE, State.SHADOWBALL:
			attack_timer.start()
			if player:
				if player.global_position.x < global_position.x:
					_set_state(State.LEFT)
				else:
					_set_state(State.RIGHT)
			else:
				_set_state(State.IDLE)
		State.DEATH:
			anim.stop()


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
	if health <= 0:
		_set_state(State.DEATH)
