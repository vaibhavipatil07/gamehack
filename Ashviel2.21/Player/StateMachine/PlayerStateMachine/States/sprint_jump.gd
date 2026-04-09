extends Motion

func _enter()-> void:
	jump()
	return super._enter()

func _update(delta: float) -> void:
	set_direction()
	calculate_gravity(delta)
	calculate_velocity(direction, player_movement_stats.acceleration, delta, sprint_speed)

	direction_updated.emit(input_dir)
	
	sprint_remaining -= delta
	
	if velocity.y <= 0:
		finished.emit("SprintFall")
	
func jump()-> void:
	velocity.y = jump_velocity
