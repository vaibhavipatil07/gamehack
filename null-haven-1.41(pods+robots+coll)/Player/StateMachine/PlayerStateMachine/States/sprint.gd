extends Motion

signal sprint_started
signal sprint_ended

func _enter() -> void:
	sprint_started.emit()
	return super._enter()


func _state_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit("SprintJump")
	
	if event.is_action_released("sprint"):
		sprint_ended.emit()
		finished.emit("Run")
		

func _update(delta: float) -> void:
	set_direction()
	calculate_velocity(direction, player_movement_stats.acceleration, delta, sprint_speed)

	direction_updated.emit(input_dir)
	
	sprint_remaining -= delta
	
	if sprint_remaining <= 0.0:
		sprint_ended.emit()
		finished.emit("Run")
	
	if direction == Vector3.ZERO:
		sprint_ended.emit()
		finished.emit("Idle")
