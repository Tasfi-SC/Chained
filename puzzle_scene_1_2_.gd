extends Node2D

var light1_on = false
var light2_on = false
var light3_on = false

var lever1_on = false
var lever2_on = false
var lever3_on = false

var solved = false
var current_lever = null

@onready var light1 = $Light1
@onready var light2 = $Light2
@onready var light3 = $Light3

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

@export var lever_up_texture: Texture2D
@export var lever_down_texture: Texture2D

func _ready():
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

func pull_lever(lever_number):
	match lever_number:
		1:
			lever1_on = !lever1_on
			light1_on = !light1_on
			light2_on = !light2_on
		2:
			lever2_on = !lever2_on
			light2_on = !light2_on
			light3_on = !light3_on
		3:
			lever3_on = !lever3_on
			light1_on = !light1_on
			light2_on = !light2_on
			light3_on = !light3_on

	update_levers()
	update_lights()

func update_lights():
	if light1_on:
		light1.texture = light_on_texture
	else:
		light1.texture = light_off_texture

	if light2_on:
		light2.texture = light_on_texture
	else:
		light2.texture = light_off_texture

	if light3_on:
		light3.texture = light_on_texture
	else:
		light3.texture = light_off_texture

	check_solution()

func update_levers():
	if lever1_on:
		lever1_sprite.texture = lever_down_texture
	else:
		lever1_sprite.texture = lever_up_texture

	if lever2_on:
		lever2_sprite.texture = lever_down_texture
	else:
		lever2_sprite.texture = lever_up_texture

	if lever3_on:
		lever3_sprite.texture = lever_down_texture
	else:
		lever3_sprite.texture = lever_up_texture

func check_solution():
	if light1_on and light2_on and light3_on and not solved:
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
