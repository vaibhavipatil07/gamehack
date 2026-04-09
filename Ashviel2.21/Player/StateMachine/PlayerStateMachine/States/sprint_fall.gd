extends Motion

@export var floor_ray_cast: RayCast3D

signal sprint_ended

func _update(delta: float) -> void:
	set_direction()
	calculate_gravity(delta)
	calculate_velocity(direction, player_movement_stats.acceleration, delta, sprint_speed)

	direction_updated.emit(input_dir)
	
	sprint_remaining -= delta
	
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			finished.emit("Sprint")
		elif direction != Vector3.ZERO:
			sprint_ended.emit()
			finished.emit("Run")
		else:
			sprint_ended.emit()
			finished.emit("Idle")
