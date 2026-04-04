extends CharacterBody2D

@export var speed: float = 90.0
@export var dash_speed: float = 260.0
@export var max_health: float = 100.0
@export var attack_cooldown: float = 2.0
@export var gravity: float = 900.0
@export var contact_damage: float = 30.0
@export var pulse_damage: float = 45.0
@export var beam_scene: PackedScene
@onready var beam_spawn: Marker2D = $BeamSpawn
enum State { IDLE, DASH, BEAM, GOD_PULSE, DEATH }

var health: float
var current_state: State = State.IDLE
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var player_in_range: bool = false
var attack_queue: Array = ["dash", "beam", "god_pulse"]
var attack_index: int = 0
var facing_left: bool = false

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

	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)

	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)

	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)

	if not pulse_area.body_entered.is_connected(_on_pulse_area_body_entered):
		pulse_area.body_entered.connect(_on_pulse_area_body_entered)

	if not anim.animation_finished.is_connected(_on_animated_sprite_2d_animation_finished):
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
			if player and player_in_range:
				_face_player()

		State.DASH:
			if player and player_in_range:
				var dir_x = sign(player.global_position.x - global_position.x)

				if dir_x < 0:
					facing_left = true
				elif dir_x > 0:
					facing_left = false

				anim.flip_h = facing_left
				velocity.x = dir_x * dash_speed
			else:
				velocity.x = 0

		State.BEAM, State.GOD_PULSE:
			velocity.x = 0
			if player and player_in_range:
				_face_player()

		State.DEATH:
			velocity = Vector2.ZERO

	move_and_slide()

func _face_player() -> void:
	if player:
		var dir_x = sign(player.global_position.x - global_position.x)
		if dir_x < 0:
			facing_left = true
		elif dir_x > 0:
			facing_left = false

	anim.flip_h = facing_left

func _set_state(new_state: State) -> void:
	current_state = new_state

	match new_state:
		State.IDLE:
			velocity.x = 0
			if player and player_in_range:
				_face_player()
			if anim.sprite_frames.has_animation("idle"):
				anim.play("idle")

		State.DASH:
			_face_player()
			if anim.sprite_frames.has_animation("dash"):
				anim.play("dash")

		State.BEAM:
			velocity.x = 0
			_face_player()
			if anim.sprite_frames.has_animation("light_beam"):
				anim.play("light_beam")

		State.GOD_PULSE:
			velocity.x = 0
			_face_player()
			if anim.sprite_frames.has_animation("god_pulse"):
				anim.play("god_pulse")

		State.DEATH:
			is_dead = true
			velocity = Vector2.ZERO
			attack_area.monitoring = false
			pulse_area.monitoring = false
			detection_area.monitoring = false
			health_bar.hide()
			if anim.sprite_frames.has_animation("death"):
				anim.play("death")
				await get_tree().create_timer(2).timeout

				queue_free()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		player = body
		player_in_range = true
		_face_player()

		if can_attack and current_state == State.IDLE:
			_trigger_next_attack()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body == player:
		player_in_range = false
		player = null
		can_attack = true
		attack_timer.stop()
		_set_state(State.IDLE)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_dead:
		return

	if current_state == State.DASH:
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)

func _on_pulse_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.GOD_PULSE and not is_dead:
		if body.has_method("take_damage"):
			body.take_damage(pulse_damage)

func _trigger_next_attack() -> void:
	if not can_attack or is_dead or not player_in_range:
		return

	can_attack = false

	var next_attack = attack_queue[attack_index]
	attack_index = (attack_index + 1) % attack_queue.size()

	match next_attack:
		"dash":
			_set_state(State.DASH)
		"beam":
			_set_state(State.BEAM)
		"god_pulse":
			_set_state(State.GOD_PULSE)

func _spawn_beam() -> void:
	if beam_scene == null:
		print("Vael beam_scene is not assigned!")
		return

	var beam = beam_scene.instantiate()
	get_parent().add_child(beam)
	beam.global_position = beam_spawn.global_position

	if facing_left:
		beam.direction = Vector2.LEFT
	else:
		beam.direction = Vector2.RIGHT
func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.DASH:
			attack_timer.start()
			_set_state(State.IDLE)

		State.BEAM:
			_spawn_beam()
			attack_timer.start()
			_set_state(State.IDLE)

		State.GOD_PULSE:
			for body in pulse_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					if body.has_method("take_damage"):
						body.take_damage(pulse_damage)
					break
			attack_timer.start()
			_set_state(State.IDLE)

		State.DEATH:
			await get_tree().create_timer(0.5).timeout
			queue_free()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if player_in_range and player and not is_dead:
		_trigger_next_attack()

func take_damage(amount: float) -> void:
	if is_dead:
		return

	health -= amount
	health_bar.value = max(health, 0)

	if health <= 0:
		health_bar.value = 0
		_set_state(State.DEATH)
