extends StateMachine

@export var player_movement_stats: MovementStats
@export var animation_controller: AnimationController

func _ready() -> void:
	for child in get_children():
		child.direction_updated.connect(animation_controller.on_character_input_direction_changed)
		child.animation_change_requested.connect(animation_controller.on_state_machine_state_change)
		
	_create_state_map()
	_set_active(false)

func _on_camera_model_view_changed(view: bool) -> void:
	_set_active(!view)
