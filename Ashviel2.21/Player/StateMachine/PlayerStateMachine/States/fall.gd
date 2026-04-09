extends Motion

@export var floor_ray_cast: RayCast3D

func _update(delta: float) -> void:
	set_direction()
	calculate_gravity(delta)
	calculate_velocity(direction, player_movement_stats.acceleration, delta)

	
	if floor_ray_cast.is_colliding():
		if direction != Vector3.ZERO:
			animation_change_requested.emit("Run")
		else:
			animation_change_requested.emit("Idle")
	
	if is_on_floor():
		if direction != Vector3.ZERO:
			finished.emit("Run")
		else:
			finished.emit("Idle")
	
