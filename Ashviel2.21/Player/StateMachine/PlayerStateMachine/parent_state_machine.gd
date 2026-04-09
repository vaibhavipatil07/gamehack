extends StateMachine

@export var weapon_manager: WeaponManager

func _ready() -> void:
	for child: CombatTransitionState in get_children():
		child.combat_status_changed.connect(weapon_manager.on_combat_status_changed)
	return super._ready()

func _change_state(state_name: String) -> void:
	if state_name == "Armed" and weapon_manager.weapons.is_empty():
		return
	
	return super._change_state(state_name)

func _on_camera_model_view_changed(view: bool) -> void:
	current_state._on_camera_model_view_changed(view)
	_set_active(!view)
