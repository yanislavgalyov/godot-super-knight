extends CharacterBody2D

@onready var dash = $dash as Dash
@export var player_stats: PlayerStats

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D

func _physics_process(delta: float)-> void:
	apply_gravity(delta)

	# Get the input direction: -1, 0, 1
	var direction: float = Input.get_axis("move_left", "move_right")

	handle_actions()
	handle_acceleration(direction, delta)
	handle_air_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)

	move_and_slide()
	update_animation(direction)

func handle_actions()-> void:
	# normal jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = player_stats.JUMP_VELOCITY
		
	# dashing
	if Input.is_action_just_pressed("dash"):
		dash.start_dashing()

func apply_gravity(delta: float)-> void:
	if not is_on_floor():
		velocity.y += gravity * player_stats.GRAVITY_SCALE * delta

func handle_acceleration(direction: float, delta: float)-> void:
	var current_speed: float = dash.get_speed() if dash.get_is_dashing() else player_stats.SPEED
	var current_acceleration: float = dash.get_acceleration() if dash.get_is_dashing() else player_stats.ACCELERATION
	
	if direction:
		velocity.x = move_toward(velocity.x, current_speed * direction, current_acceleration * delta)
	else: 
		velocity.x = move_toward(velocity.x, 0, current_speed)

func handle_air_acceleration(direction: float, delta: float)-> void:
	if is_on_floor(): 
		return
	if direction != 0:
		velocity.x = move_toward(velocity.x, player_stats.SPEED * direction, player_stats.AIR_ACCELERATION * delta)

func apply_friction(direction: float, delta: float)-> void:
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, player_stats.FRICTION * delta)
		
func apply_air_resistance(direction: float, delta: float)-> void:
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, player_stats.AIR_RESISTANCE * delta)
		
func update_animation(direction: float)-> void:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
