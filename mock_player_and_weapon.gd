extends Node

# We put these signals here so the HUD can find them
signal health_changed(val: float)
signal food_changed(val: float)
signal ammo_changed(current: int, max_val: int)

var current_health: float = 100.0
var current_food: float = 100.0
var current_ammo: int = 30
var max_ammo: int = 30
var cores_destroyed: int = 0

func _ready() -> void:
	# 1. Add this node to the groups the HUD is looking for
	add_to_group("player")
	add_to_group("weapon")
	
	# 2. Give the HUD a moment to connect its signals, then send initial values
	await get_tree().process_frame
	health_changed.emit(current_health)
	food_changed.emit(current_food)
	ammo_changed.emit(current_ammo, max_ammo)
	
	# 3. Set the objective text
	var hud = get_parent().get_node("HUD")
	if hud and hud.has_method("set_objective"):
		hud.set_objective("Reach the Power Station\nand shut off main switch [E]")

func _process(delta: float) -> void:
	# -- TEST CONTROLS --
	
	# Press 'H' to take damage
	if Input.is_action_just_pressed("ui_text_caret_left"): # Using default left arrow just for testing, or map a key
		pass 
	if Input.is_physical_key_pressed(KEY_H): 
		current_health = clamp(current_health - 10 * delta, 0, 100)
		health_changed.emit(current_health)

	# Press 'F' to lose food
	if Input.is_physical_key_pressed(KEY_F):
		current_food = clamp(current_food - 5 * delta, 0, 100)
		food_changed.emit(current_food)

	# Press 'Space' to shoot
	if Input.is_physical_key_pressed(KEY_SPACE) and current_ammo > 0:
		current_ammo -= 1
		ammo_changed.emit(current_ammo, max_ammo)

	# Press 'R' to reload
	if Input.is_physical_key_pressed(KEY_R):
		current_ammo = max_ammo
		ammo_changed.emit(current_ammo, max_ammo)

	# Press 'P' to toggle the power (Timer)
	if Input.is_action_just_pressed("ui_accept"): # Or just map 'P'
		pass
	if Input.is_physical_key_pressed(KEY_P) and Input.is_action_just_pressed("ui_focus_next") == false: # simple debounce
		GameManager.power_is_off = !GameManager.power_is_off
		GameManager.power_toggled.emit(GameManager.power_is_off)

	# Press 'C' to destroy a core
	if Input.is_physical_key_pressed(KEY_C):
		cores_destroyed += 1
		if cores_destroyed <= 3:
			GameManager.core_destroyed.emit(cores_destroyed)

	# Make the timer tick down if power is off
	if GameManager.power_is_off:
		GameManager.freeze_timer_remaining -= delta
