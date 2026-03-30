extends CharacterBody2D
@export var speed: float = 80.0
@export var health: float = 500.0
@export var attack_cooldown: float = 5.0

enum State { IDLE, WALK, SLAM, SWEEP, SUMMON, DEAD }
var current_state: State = State.IDLE
# --- References ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var phase_timer: Timer = $PhaseTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var shockwave_area: Area2D = $ShockwaveArea
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var attack_landed: bool = false
var attack_queue: Array = ["slam", "sweep", "summon"]
var attack_index: int = 0
func _ready()->void: 
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	shockwave_area.body_entered.connect(_on_shockwave_area_body_entered)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	_set_state(State.IDLE)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.WALK:
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				anim.flip_h = direction.x < 0
			else:
				_set_state(State.IDLE)
		State.SLAM, State.SWEEP, State.SUMMON:
			velocity = Vector2.ZERO

	move_and_slide()
	
func _set_state(new_state: State) -> void:
	current_state = new_state
	attack_landed = false  
	match new_state:
		State.IDLE:   anim.play("idle")
		State.WALK:   anim.play("walk")
		State.SLAM:   anim.play("slam")
		State.SWEEP:  anim.play("sweep")
		State.SUMMON: anim.play("summon")
		State.DEAD:
			anim.play("dead")
			is_dead = true
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		player = body
		_set_state(State.WALK)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		can_attack = true
		attack_landed = false
		attack_timer.stop()
		_set_state(State.IDLE)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_dead:
		return
	# If currently attacking with slam or sweep, deal damage
	if current_state == State.SLAM or current_state == State.SWEEP:
		_deal_percent_damage(body)
	# If not attacking yet and cooldown is ready, trigger next attack
	elif can_attack:
		_trigger_next_attack()
func _trigger_next_attack() -> void:
	if not can_attack or is_dead:
		return
	can_attack = false
	attack_landed = false

	var next_attack = attack_queue[attack_index]
	attack_index = (attack_index + 1) % attack_queue.size()

	match next_attack:
		"slam":   _set_state(State.SLAM)
		"sweep":  _set_state(State.SWEEP)
		"summon": _set_state(State.SUMMON)
		
func _deal_percent_damage(body: Node2D) -> void:
	if attack_landed:
		return
	attack_landed = true
	var damage = body.health * 0.25  # 25% of player's CURRENT hp
	body.take_damage(damage)

func _on_shockwave_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.SUMMON and not is_dead:
		_deal_percent_damage(body)
func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.SLAM, State.SWEEP, State.SUMMON:
			attack_timer.start()
			if player:
				_set_state(State.WALK)
			else:
				_set_state(State.IDLE)
		State.DEAD:
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
		_set_state(State.DEAD)
