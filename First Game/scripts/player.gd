extends CharacterBody2D

@export var player_stats: PlayerStats
@export_range(0, 10) var coyote_frames: int = 4
@export_range(0, 10) var wall_jump_frames: int = 4
@export_range(0, 10) var jump_buffer_frames: int = 4

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var physics_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second") # Engine.physics_ticks_per_second

@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var actionable_finder = $ActionableFinder as Area2D
@onready var coyote_timer = $CoyoteTimer as Timer
@onready var wall_timer = $WallTimer as Timer
@onready var dash_duration_timer = $DashDurationTimer as Timer
@onready var dash_cooldown_timer = $DashCooldownTimer as Timer
@onready var jump_buffer_timer = $JumpBufferTimer as Timer

var was_wall_normal: Vector2

var is_dashing: bool = false
var can_dash: bool = true

var jump_buffer: bool = false

func _ready()-> void:
	# https://www.reddit.com/r/godot/comments/16bormn/comment/jzgsdyd/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
	safe_margin = 0.1

	coyote_timer.wait_time = float(coyote_frames) / physics_ticks_per_second
	wall_timer.wait_time = float(wall_jump_frames) / physics_ticks_per_second

	dash_duration_timer.wait_time = player_stats.DASH_DURATION
	dash_duration_timer.timeout.connect(_on_dash_duration_timer_timeout)

	dash_cooldown_timer.wait_time = player_stats.DASH_COOLDOWN
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)

	jump_buffer_timer.wait_time = float(jump_buffer_frames) / physics_ticks_per_second
	jump_buffer_timer.timeout.connect(_on_jump_buffer_timeout)

func _physics_process(delta: float)-> void:
	if Input.is_action_just_pressed("interact"):
		var actionables: Array[Area2D] = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return

	apply_gravity(delta)

	# Get the input direction: -1, 0, 1
	var direction: float = Input.get_axis("move_left", "move_right")

	handle_actions(direction, delta)
	handle_acceleration(direction, delta)
	handle_air_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)

	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()

	move_and_slide()

	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()

	# timer starts at the first frame the player is on_wall_only
	if was_on_wall:
		wall_timer.start()

	update_animation(direction)

func handle_actions(direction: float, delta: float)-> void:
	# EXPERIMENTAL - control jump height, but it is not great when wall jumping
	#if Input.is_action_just_released("jump") and velocity.y < 0:
		#velocity.y = player_stats.JUMP_VELOCITY / 2

	if Input.is_action_just_pressed("jump") or jump_buffer:
		# normal jump
		if is_on_floor() or coyote_timer.time_left > 0.0:
			velocity.y = player_stats.JUMP_VELOCITY
			coyote_timer.stop()
			jump_buffer_timer.stop()
			jump_buffer = false
		# wall jump
		elif wall_timer.time_left > 0.0:
			if direction == was_wall_normal.x:
				velocity = Vector2(move_toward(velocity.x, player_stats.SPEED * direction, player_stats.ACCELERATION * delta), player_stats.JUMP_VELOCITY)
		elif not jump_buffer:
			jump_buffer = true
			jump_buffer_timer.start()

	# dashing
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			is_dashing = true
			can_dash = false
			dash_duration_timer.start()
			dash_cooldown_timer.start()

func apply_gravity(delta: float)-> void:
	var gravity_scale: float = player_stats.GRAVITY_SCALE_UP if velocity.y < 0.0 else player_stats.GRAVITY_SCALE_DOWN
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta

func handle_acceleration(direction: float, delta: float)-> void:
	var current_speed: float = player_stats.DASH_SPEED if is_dashing else player_stats.SPEED
	var current_acceleration: float = player_stats.DASH_ACCELERATION if is_dashing else player_stats.ACCELERATION

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
		if velocity.y > 0.0:
			animated_sprite.play("fall")
		else:
			animated_sprite.play("jump")

func _on_dash_duration_timer_timeout()-> void:
	is_dashing = false

func _on_dash_cooldown_timeout()-> void:
	can_dash = true

func _on_jump_buffer_timeout()-> void:
	jump_buffer = false
