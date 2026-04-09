extends Node3D
class_name WeaponManager

signal weapon_changed(_weapon: Weapon, _weapon_model: WeaponModel)
signal weapon_manager_started(status:String ,_weapon:Weapon, _weapon_model: WeaponModel)
signal weapon_manager_finished(status: String, weapons_is_empty: bool)
signal weapon_fired
signal weapon_reloaded
signal ammo_updated(_weapon: Weapon)

enum WeaponManagerStatus{AVAILABLE,UNAVAILABLE}

@export var weapons: Array[Weapon]
@export var weapon_status_timer: Timer

var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
var current_weapon: Weapon
var current_weapon_model: WeaponModel
var action_queue: Callable
var change_weapon_wait_time: float = 0.0
var reload_weapon_wait_time: float = 0.0
var shoot_weapon_wait_time: float = 0.0

func _ready() -> void:
	if weapons.is_empty():
		return
	current_weapon = weapons[0]
	set_weapon_wait_time(current_weapon)

func _input(event: InputEvent) -> void:
	if current_status == WeaponManagerStatus.AVAILABLE:
		if event.is_action_pressed("weapon_up"):
			var weapon_index: int = weapons.find(current_weapon)
			weapon_index = min(weapon_index+1, weapons.size()-1)
			change_weapon(weapon_index)
			
		if event.is_action_pressed("weapon_down"):
			var weapon_index: int = weapons.find(current_weapon)
			weapon_index = max(weapon_index-1, 0)
			change_weapon(weapon_index)
			
		if event.is_action_pressed("shoot"):
			shoot()
			
		if event.is_action_pressed("reload"):
			reload()

func on_combat_status_changed(status: String) -> void:
	match status:
		"non_combat":
			weapon_manager_finished.emit(status, weapons.is_empty())
			set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
			weapon_status_timer.stop()
		"combat":
			start_weapon_manager(status)
			

func set_weapon_manager_status(status: WeaponManagerStatus) -> void:
	current_status = status

func start_weapon_manager(status: String) -> void:
	set_current_weapon_model(current_weapon)
	weapon_manager_started.emit(status,current_weapon, current_weapon_model)
	wait_for_action_completion(change_weapon_wait_time)
	
func change_weapon(index: int) -> void:
	if weapons[index] == current_weapon:
		return
		
	current_weapon = weapons[index]
	set_weapon_wait_time(current_weapon)
	set_current_weapon_model(current_weapon)
	weapon_changed.emit(current_weapon, current_weapon_model)
	ammo_updated.emit(current_weapon)
	wait_for_action_completion(change_weapon_wait_time)
	
func wait_for_action_completion(wait_time: float, action: Callable = Callable()) -> void:
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	weapon_status_timer.start(wait_time)
	action_queue = action

func set_weapon_wait_time(_weapon: Weapon) -> void:
	reload_weapon_wait_time = _weapon.weapon_reload_animation.length
	shoot_weapon_wait_time = _weapon.weapon_shoot_animation.length
	change_weapon_wait_time = _weapon.weapon_change_animation.length

func _on_weapon_status_timer_timeout() -> void:
	set_weapon_manager_status(WeaponManagerStatus.AVAILABLE)
	
	if action_queue.is_valid():
		action_queue.call_deferred()
		action_queue = Callable()
	
func check_auto_fire() -> void:
	if current_weapon.auto_fire and Input.is_action_pressed("shoot"):
		shoot()

func shoot() -> void:
	if current_weapon.current_ammo:
		if current_weapon.current_ammo.ammount > 0:
			weapon_fired.emit()
			wait_for_action_completion(shoot_weapon_wait_time, check_auto_fire)
			var _projectile: Projectile = get_projectile()
			add_child(_projectile)
			_projectile._set_weapon_projectile(current_weapon,current_weapon_model)
			current_weapon.current_ammo.ammount -= 1
			ammo_updated.emit(current_weapon)
		else:
			reload()
			
func get_projectile()-> Projectile:
	var _projectile: Projectile
	_projectile = current_weapon.current_ammo.projectile.instantiate()
	return _projectile
	
func reload() -> void:
	if current_weapon.reserve_ammo.size()>0:
		weapon_reloaded.emit()
		wait_for_action_completion(reload_weapon_wait_time, calculate_reload)
	
func calculate_reload() -> void:
	if current_weapon.current_ammo:
		if current_weapon.current_ammo.ammount > 0:
			current_weapon.reserve_ammo.push_back(current_weapon.current_ammo)
			
	if current_weapon.reserve_ammo.size() >0:
		current_weapon.current_ammo = current_weapon.reserve_ammo.pop_front().duplicate()
		
	ammo_updated.emit(current_weapon)

func set_current_weapon_model(_weapon: Weapon) -> void:
	var new_model: WeaponModel = _weapon.weapon_model.instantiate()
	current_weapon_model = new_model


func _on_weapon_pick_up_area_ammo_detected(ammo_pick_up: AmmoPickUp) -> void:
	var pick_up: Array = add_ammo(ammo_pick_up.pick_up.duplicate())
	if pick_up.is_empty():
		ammo_pick_up.queue_free()

func add_ammo(ammo: Array[Ammo]) -> Array:
	var ammo_taken: int = ammo.size()
	for i in ammo.size():
		for j in weapons:
			if ammo[i].ammo_type == j.name:
				if (j.reserve_ammo.size() >= j.max_ammo_clips) and j.override_max_ammo == false:
					pass
				else:
					ammo_taken -= 1
					j.reserve_ammo.push_back(ammo[i])
					break
	
	ammo.resize(ammo_taken)
	ammo_updated.emit(current_weapon)
	return ammo

func _on_weapon_pick_up_area_weapon_detected(weapon_pick_up: WeaponPickUp) -> void:
	if not weapons.has(weapon_pick_up.weapon_pick_up):
		add_weapon(weapon_pick_up)
		weapon_pick_up.queue_free()
	else:
		var _pick_up: Array[Ammo]
		_pick_up.append_array(weapon_pick_up.ammo_pick_up)
		_pick_up = add_ammo(_pick_up)
		
		if _pick_up.is_empty():
			weapon_pick_up.queue_free()
		else:
			weapon_pick_up.ammo_pick_up = _pick_up
		
func add_weapon(weapon_pick_up: WeaponPickUp) -> void:
	var _weapon: Weapon = weapon_pick_up.weapon_pick_up
	_weapon.reserve_ammo.append_array(weapon_pick_up.ammo_pick_up)
	if not _weapon.reserve_ammo.is_empty():
		_weapon.current_ammo = _weapon.reserve_ammo.pop_front()
	
	weapons.push_back(_weapon)
	if not current_weapon:
		current_weapon = weapons[0]
		set_weapon_wait_time(current_weapon)

func drop_weapon() -> float:
	var weapon_to_load : WeaponPickUp = current_weapon.weapon_to_drop.instantiate()
	weapon_to_load.weapon_pick_up = current_weapon
	weapon_to_load.global_transform = current_weapon_model.global_transform
	
	weapon_to_load.ammo_pick_up.append_array(current_weapon.reserve_ammo)
	current_weapon.reserve_ammo.clear()
	weapon_to_load.ammo_pick_up.append(current_weapon.current_ammo)
	current_weapon.current_ammo = null
	
	current_weapon_model.queue_free()
	get_tree().get_root().add_child(weapon_to_load)
	
	var weapon_index: int = weapons.find(current_weapon)
	weapons.remove_at(weapon_index)
	
	weapon_index = max(weapon_index-1,0)
	
	if weapons.size() == 0:
		current_weapon = null
	else:
		change_weapon(weapon_index)
		
	return weapons.size()
	
	
	
	
	
	
	
	
	
	
	
	
