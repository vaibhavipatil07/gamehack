extends Motion

func _state_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit("Jump")

	if event.is_action_pressed("sprint") and sprint_remaining > player_movement_stats.minimum_sprint_threshold:
		finished.emit("Sprint")

	if event.is_action_pressed("aim"):
		finished.emit("AimWalk")

func _update(delta: float) -> void:
	set_direction()
	calculate_velocity(direction, player_movement_stats.acceleration, delta)
	replenish_sprint(delta)
	direction_updated.emit(input_dir)

	if direction == Vector3.ZERO:
		finished.emit("Idle")

	if not is_on_floor():
		finished.emit("Fall")
