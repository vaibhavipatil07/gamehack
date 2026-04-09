extends State
class_name CombatTransitionState

signal combat_status_changed(_status: String)

@export var state_machine: StateMachine
@export var status: String

func _enter() -> void:
	state_machine._initialize(state_machine.start_state)
	combat_status_changed.emit(status)

func _exit() -> void:
	state_machine._set_active(false)
