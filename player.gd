extends CharacterBody3D
class_name PortablePlayer

@export var max_health: int = 100
var health: int
@export var auto_register_input_actions: bool = true
@onready var collision: CollisionShape3D = $CollisionShape3D

const STAND_HEIGHT: float = 1.8
const CROUCH_HEIGHT: float = 1.0
const SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8
var is_crouching: bool = false

func _ready():
	health = max_health
	add_to_group("player")
	if auto_register_input_actions:
		_ensure_input_actions()

func take_damage(amount: float, source: Node = null):
	health -= int(amount)
	print("Player Health:", health)
	if health <= 0:
		die()

func die():
	print("You died")
	queue_free()

func _physics_process(delta: float) -> void:
	# Crouch collision height
	var capsule: CapsuleShape3D = collision.shape as CapsuleShape3D
	if capsule:
		capsule.height = CROUCH_HEIGHT if is_crouching else STAND_HEIGHT

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement direction
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.y = Input.get_action_strength("down")  - Input.get_action_strength("up")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Speed
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	if is_crouching:
		speed *= 0.5

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Crouch toggle
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	# Shooting raycast
	if Input.is_action_just_pressed("shoot"):
		var camera := get_viewport().get_camera_3d()
		if camera:
			var space := get_world_3d().direct_space_state
			var from := camera.global_position
			var to := from + (-camera.global_transform.basis.z * 100.0)
			var query := PhysicsRayQueryParameters3D.create(from, to)
			query.exclude = [self]
			var result := space.intersect_ray(query)
			if result:
				var hit: Node = result.collider as Node
				if hit.is_in_group("hurtbox"):
					hit.receive_damage(25.0, self)
				elif hit.has_method("take_damage"):
					hit.take_damage(25.0, self)

	move_and_slide()

# -------- INPUT SYSTEM --------
const INPUT_ACTIONS := {
	"left": [KEY_A],
	"right": [KEY_D],
	"up": [KEY_W],
	"down": [KEY_S],
	"jump": [KEY_SPACE],
	"sprint": [KEY_SHIFT],
	"reload": [KEY_R],
	"holster_weapon": [KEY_Q],
	"drop": [KEY_G],
	"crouch": [KEY_CTRL],
	"swap_camera_alignment": [KEY_V],
	"model_view": [KEY_TAB],
	"weapon_up": [],
	"weapon_down": [],
}

const MOUSE_ACTIONS := {
	"aim": MOUSE_BUTTON_RIGHT,
	"shoot": MOUSE_BUTTON_LEFT,
	"weapon_up": MOUSE_BUTTON_WHEEL_UP,
	"weapon_down": MOUSE_BUTTON_WHEEL_DOWN,
}

func _ensure_input_actions() -> void:
	for action: String in INPUT_ACTIONS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for keycode: int in INPUT_ACTIONS[action]:
				var event := InputEventKey.new()
				event.physical_keycode = keycode
				InputMap.action_add_event(action, event)
	for action: String in MOUSE_ACTIONS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_ACTIONS[action]
			InputMap.action_add_event(action, event)
