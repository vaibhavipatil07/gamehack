extends State
class_name Motion

signal velocity_updated(vel: Vector3)

@warning_ignore("unused_signal")
signal direction_updated(dir: Vector2)

@warning_ignore("unused_signal")
signal animation_change_requested(animation: String)

@export var on_enter_animation: String = ""

var player_movement_stats: MovementStats
var speed: float = 0.0
var sprint_speed: float = 0.0
var aim_speed: float = 0.0
var crouch_speed: float = 0.0
var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var fall_gravity: float = 0.0

static var input_dir: Vector2 = Vector2.ZERO
static var direction: Vector3 = Vector3.ZERO
static var velocity: Vector3 = Vector3.ZERO
static var sprint_remaining: float = 0.0

func _ready() -> void:
	player_movement_stats = get_parent().get("player_movement_stats") as MovementStats
	if player_movement_stats == null:
		push_error("Motion state %s could not find player_movement_stats on parent state machine." % name)
		return

	sprint_remaining = player_movement_stats.sprint_duration
	if owner and owner.has_method("set_velocity_from_motion"):
		velocity_updated.connect(owner.set_velocity_from_motion)

	speed = player_movement_stats.get_velocity(
		player_movement_stats.jump_distance,
		player_movement_stats.time_to_jump_apex + player_movement_stats.time_to_land
	)
	sprint_speed = player_movement_stats.get_velocity(
		player_movement_stats.sprint_jump_distance,
		player_movement_stats.time_to_jump_apex + player_movement_stats.time_to_land
	)
	aim_speed = player_movement_stats.get_velocity(
		player_movement_stats.aim_jump_distance,
		player_movement_stats.time_to_jump_apex + player_movement_stats.time_to_land
	)
	crouch_speed = speed * 0.5

	jump_gravity = player_movement_stats.get_jump_gravity()
	fall_gravity = player_movement_stats.get_fall_gravity()
	jump_velocity = player_movement_stats.get_jump_velocity(jump_gravity)

func _enter() -> void:
	if on_enter_animation != "":
		animation_change_requested.emit(on_enter_animation)

func handle_crouch() -> void:
	if not owner:
		return

	if Input.is_action_pressed("crouch"):
		if not bool(owner.get("is_crouching")):
			owner.call("set_crouching", true)
			animation_change_requested.emit("crouch")
	else:
		if bool(owner.get("is_crouching")):
			owner.call("set_crouching", false)
			animation_change_requested.emit("idle")

func set_direction() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (owner.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

func calculate_velocity(_direction: Vector3, acceleration: float, delta: float, target_speed: float = -1.0) -> void:
	var current_speed: float = target_speed
	if current_speed < 0.0:
		current_speed = crouch_speed if bool(owner.get("is_crouching")) else speed

	velocity.x = move_toward(velocity.x, _direction.x * current_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, _direction.z * current_speed, acceleration * delta)
	velocity_updated.emit(velocity)

func calculate_gravity(delta: float) -> void:
	if not owner.is_on_floor():
		if velocity.y > 0.0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta

func is_on_floor() -> bool:
	return owner.is_on_floor()

func replenish_sprint(delta: float, replenishment_rate: float = 1.0) -> void:
	sprint_remaining = min(
		sprint_remaining + (delta * replenishment_rate),
		player_movement_stats.sprint_duration
	)
