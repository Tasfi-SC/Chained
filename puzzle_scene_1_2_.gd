extends Node2D

var light1_on = false
var light2_on = true
var light3_on = false
var light4_on = false

# 0 = neutral, 1 = up, 2 = down
var lever1_state = 0
var lever2_state = 0
var lever3_state = 0

var solved = false
var current_lever = null

@onready var light1 = $Light1
@onready var light2 = $Light2
@onready var light3 = $Light3
@onready var light4 = $Light4

@onready var lever1_sprite = $Lever1/Sprite2D
@onready var lever2_sprite = $Lever2/Sprite2D
@onready var lever3_sprite = $Lever3/Sprite2D

@onready var lever1_area = $Lever1/Area2D
@onready var lever2_area = $Lever2/Area2D
@onready var lever3_area = $Lever3/Area2D

@onready var portal = $Portal
@onready var interact_label = $InteractLabel

@export var light_off_texture: Texture2D
@export var light_on_texture: Texture2D

@export var lever_neutral_texture: Texture2D
@export var lever_up_texture: Texture2D
@export var lever_down_texture: Texture2D

func _ready():
	light1_on = false
	light2_on = true
	light3_on = false
	light4_on = false

	lever1_state = 0
	lever2_state = 0
	lever3_state = 0

	update_lights()
	update_levers()

	lever1_area.body_entered.connect(_on_lever1_body_entered)
	lever1_area.body_exited.connect(_on_lever1_body_exited)

	lever2_area.body_entered.connect(_on_lever2_body_entered)
	lever2_area.body_exited.connect(_on_lever2_body_exited)

	lever3_area.body_entered.connect(_on_lever3_body_entered)
	lever3_area.body_exited.connect(_on_lever3_body_exited)

	portal.visible = false
	interact_label.visible = false

func _process(_delta):
	if solved:
		interact_label.visible = false
		return

	if current_lever != null:
		interact_label.visible = true
		interact_label.global_position = get_lever_label_position(current_lever)
	else:
		interact_label.visible = false

	if current_lever != null and Input.is_action_just_pressed("interact"):
		pull_lever(current_lever)

func get_lever_label_position(lever_number):
	match lever_number:
		1:
			return $Lever1.global_position + Vector2(-20, -50)
		2:
			return $Lever2.global_position + Vector2(-20, -50)
		3:
			return $Lever3.global_position + Vector2(-20, -50)
	return Vector2.ZERO

func advance_lever_state(current_state):
	if current_state == 0:
		return 2
	elif current_state == 2:
		return 1
	else:
		return 2

func pull_lever(lever_number):
	match lever_number:
		1:
			lever1_state = advance_lever_state(lever1_state)
			light1_on = !light1_on
			light2_on = !light2_on
		2:
			lever2_state = advance_lever_state(lever2_state)
			light2_on = !light2_on
			light3_on = !light3_on
		3:
			lever3_state = advance_lever_state(lever3_state)
			light1_on = !light1_on
			light3_on = !light3_on
			light4_on = !light4_on

	update_levers()
	update_lights()

func update_lights():
	light1.texture = light_on_texture if light1_on else light_off_texture
	light2.texture = light_on_texture if light2_on else light_off_texture
	light3.texture = light_on_texture if light3_on else light_off_texture
	light4.texture = light_on_texture if light4_on else light_off_texture
	check_solution()

func update_levers():
	update_one_lever_sprite(lever1_sprite, lever1_state)
	update_one_lever_sprite(lever2_sprite, lever2_state)
	update_one_lever_sprite(lever3_sprite, lever3_state)

func update_one_lever_sprite(sprite, state):
	if state == 0:
		sprite.texture = lever_neutral_texture
	elif state == 1:
		sprite.texture = lever_up_texture
	else:
		sprite.texture = lever_down_texture

func check_solution():
	if light1_on and light2_on and light3_on and light4_on and not solved:
		solved = true
		portal.visible = true
		interact_label.visible = false

func _on_lever1_body_entered(body):
	if body.is_in_group("player"):
		current_lever = 1

func _on_lever1_body_exited(body):
	if body.is_in_group("player") and current_lever == 1:
		current_lever = null

func _on_lever2_body_entered(body):
	if body.is_in_group("player"):
		current_lever = 2

func _on_lever2_body_exited(body):
	if body.is_in_group("player") and current_lever == 2:
		current_lever = null

func _on_lever3_body_entered(body):
	if body.is_in_group("player"):
		current_lever = 3

func _on_lever3_body_exited(body):
	if body.is_in_group("player") and current_lever == 3:
		current_lever = null
