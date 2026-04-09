extends CharacterBody3D
class_name PortablePlayer

@export var auto_register_input_actions: bool = true
@onready var collision: CollisionShape3D = $CollisionShape3D

const STAND_HEIGHT: float = 1.8
const CROUCH_HEIGHT: float = 1.0

var is_crouching: bool = false

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

func _ready() -> void:
	if auto_register_input_actions:
		_ensure_input_actions()

func set_velocity_from_motion(vel: Vector3) -> void:
	velocity = vel

func set_crouching(value: bool) -> void:
	is_crouching = value

func _physics_process(_delta: float) -> void:
	var capsule: CapsuleShape3D = collision.shape as CapsuleShape3D
	if capsule:
		capsule.height = CROUCH_HEIGHT if is_crouching else STAND_HEIGHT
	move_and_slide()

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
