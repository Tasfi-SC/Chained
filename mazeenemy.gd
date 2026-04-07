extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
var player: Node2D
var speed = 80.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$restart.body_entered.connect(_on_restart_body_entered)

func _physics_process(delta):
	if not player:
		return	
	# updates to followwhere the player is - where to go
	nav_agent.target_position = player.global_position
	
	var next_pos = nav_agent.get_next_path_position() # gets best path to get to player
	var direction = (next_pos - global_position).normalized()  # calculate the direction to the path
	velocity = velocity.lerp(direction * speed, 0.05) # fix harsh corners so doesnt get stuck
	move_and_slide()
	
func _on_restart_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body.is_in_group("player"):
		get_tree().call_deferred("reload_current_scene")
