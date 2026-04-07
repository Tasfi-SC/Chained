extends CharacterBody2D
@export var max_health: float = 600.0
@export var speed: float = 200.0
@export var jump_velocity: float = -500.0
@export var gravity: float = 900.0
var can_move := true
var in_water: bool = false
@export var water_slow_multiplier: float = 0.5

@export var shadow_ball_unlocked: bool = true
@export var sword_unlocked: bool = true
@export var demon_form_unlocked: bool = true

@export var dodge_speed: float = 600.0
@export var dodge_duration: float = 0.3
@export var dodge_cooldown_human: float = 5.0
@export var dodge_cooldown_demon: float = 2.0

@export var ball_cooldown: float = 0.5
@export var sword_cooldown: float = 0.8
@export var pulse_cooldown: float = 5.0
@export var pulse_hp_cost: float = 10.0

@export var ball_scene: PackedScene
@export var ball_speed: float = 400.0
	
var health: float
var demon_form: bool = false
var is_dodging: bool = false
var is_invincible: bool = false
var sword_active: bool = false
var is_attacking: bool = false
var is_dead: bool = false
var facing_right: bool = true
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var ball_cooldown_timer: float = 0.0
var sword_cooldown_timer: float = 0.0
var pulse_cooldown_timer: float = 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var camera: Camera2D = $Camera2D
@onready var attack_collision: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
signal hp_changed(new_hp, max_hp)
signal player_died
signal demon_form_activated
signal ability_unlocked(ability_name)
func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	attack_collision.disabled = true
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	floor_snap_length = 10.0  
	floor_max_angle = deg_to_rad(70)
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_update_timers(delta)
	_apply_gravity(delta)
	if not can_move:
		velocity.x = 0.0
		_play_anim("idle")
		move_and_slide()
		return
	if not is_attacking:
		_handle_movement(delta)
		_handle_jump()
		_handle_dodge(delta)

	if not is_dodging and not is_attacking:
		_handle_attacks()

	_update_animation()
	move_and_slide()
	
func _update_timers(delta: float) -> void:
	dodge_cooldown_timer = max(0.0, dodge_cooldown_timer - delta)
	ball_cooldown_timer = max(0.0, ball_cooldown_timer - delta)
	sword_cooldown_timer = max(0.0, sword_cooldown_timer - delta)
	pulse_cooldown_timer = max(0.0, pulse_cooldown_timer - delta)

	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0.0:
			is_dodging = false
			is_invincible = false
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
func _handle_movement(delta: float) -> void:
	var direction: float = 0.0

	if Input.is_action_pressed("move_right"):
		direction = 1.0
		facing_right = true
		sprite.flip_h = false
	elif Input.is_action_pressed("move_left"):
		direction = -1.0
		facing_right = false
		sprite.flip_h = true
	
	if not is_dodging:
		var current_speed = speed
		if in_water:
			# print("in water")
			current_speed *= water_slow_multiplier
		if direction != 0.0:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_speed)
func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
func _handle_dodge(delta: float) -> void:
	if Input.is_action_just_pressed("dodge") and not is_dodging:
		var cooldown = dodge_cooldown_demon if demon_form else dodge_cooldown_human
		if dodge_cooldown_timer <= 0.0:
			is_dodging = true
			is_invincible = true
			dodge_timer = dodge_duration
			dodge_cooldown_timer = cooldown
			velocity.x = dodge_speed * (1.0 if facing_right else -1.0)
			_play_anim("dodge")
func _handle_attacks() -> void:
	# Melee / Sword
	if Input.is_action_just_pressed("attack_melee"):
		if sword_unlocked and sword_cooldown_timer <= 0.0:
			_do_sword_attack()
			$AnimationPlayer.play("attack")
		elif not sword_unlocked:
			_do_melee()
	if Input.is_action_just_pressed("attack_ball") and shadow_ball_unlocked:
		if ball_cooldown_timer <= 0.0:
			_do_shadow_ball()
			$AnimationPlayer.play("shadowball")
func _do_melee() -> void:
	is_attacking = true
	_play_anim("melee")
	attack_collision.disabled = false
	await get_tree().create_timer(0.9).timeout
	attack_collision.disabled = true
	is_attacking = false
	_play_anim("idle") 
func _do_sword_attack() -> void:
	is_attacking = true
	sword_cooldown_timer = sword_cooldown
	_play_anim("sword_slash")
	$AnimationPlayer.play("attack")
	attack_collision.disabled = false
	await get_tree().create_timer(0.9).timeout
	attack_collision.disabled = true
	is_attacking = false
	_play_anim("idle") 
func _do_shadow_ball() -> void:
	is_attacking = true
	ball_cooldown_timer = ball_cooldown
	_play_anim("shadow_ball")
	$AnimationPlayer.play("shadowball")

	await get_tree().create_timer(0.9).timeout
	is_attacking = false
	_play_anim("idle") 
	if ball_scene:
		var shot_count = 3 if demon_form else 1
		for i in range(shot_count):
			var ball = ball_scene.instantiate()
			get_parent().add_child(ball)
			ball.global_position = global_position + Vector2(40 if facing_right else -40, -10)
			ball.direction = Vector2.RIGHT if facing_right else Vector2.LEFT
			ball.speed = ball_speed
			ball.is_demon = demon_form
			if shot_count > 1:
				await get_tree().create_timer(0.1).timeout
func take_damage(amount: float) -> void:
	health -= amount
	if health < 0:
		health = 0
	health_bar.value = health
	print("Player took ", amount, " damage. HP: ", health)

	if health <= 0:
		_die()
		return

	_play_anim("hurt")
	# Brief invincibility after getting hit
	is_invincible = true
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
func _die() -> void:
	is_dead = true
	is_invincible = true
	health_bar.value = 0
	_play_anim("death")
	emit_signal("player_died")
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = true
func activate_demon_form() -> void:
	demon_form = true
	demon_form_unlocked = true
	_play_anim("demon_transform")
	await get_tree().create_timer(1.0).timeout
	emit_signal("demon_form_activated")
func unlock_ability(ability: String) -> void:
	match ability:
		"shadow_ball":
			shadow_ball_unlocked = true
			
		"sword":
			sword_unlocked = true
		"demon_form":
			activate_demon_form()
	emit_signal("ability_unlocked", ability)
func _play_anim(anim_name: String) -> void:
	var prefix = "demon_" if demon_form else ""
	var full_name = prefix + anim_name

	# Fallback to human anim if demon anim doesn't exist yet
	if sprite.sprite_frames.has_animation(full_name):
		sprite.play(full_name)
	elif sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
func _update_animation() -> void:
	if is_attacking or is_dodging or is_dead:
		return

	if not is_on_floor():
		if velocity.y < 0:
			_play_anim("jump_up")
		else:
			_play_anim("jump_down")
	elif abs(velocity.x) > 10:
		_play_anim("run")
	else:
		_play_anim("idle")
func _on_animation_finished() -> void:
	var anim = sprite.animation
	# Reset attacking state after attack animations finish
	if "melee" in anim or "slash" in anim or "swing" in anim \
	or "ball" in anim or "pulse" in anim or "hurt" in anim \
	or "exhaust" in anim or "dodge" in anim:
		is_attacking = false
		attack_collision.disabled = true
		_play_anim("idle") 
func get_hp_percent() -> float:
	return health/max_health

func get_dodge_cooldown_percent() -> float:
	var cooldown = dodge_cooldown_demon if demon_form else dodge_cooldown_human
	return 1.0 - (dodge_cooldown_timer / cooldown)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		var dmg = 10.0
		if area.get("damage") != null:
			dmg = area.damage
		take_damage(dmg)


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(20.0)
