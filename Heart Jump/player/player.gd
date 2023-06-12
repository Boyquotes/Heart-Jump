extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

const SPEED = 100.0
const ACCELERATION = 550.0
const FRICTION = 550.0
const JUMP_VELOCITY = -275.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	apply_gravity(delta)
	jump()
	var input_axis = Input.get_axis("move_left", "move_right")
	apply_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	play_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2

func apply_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func play_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
