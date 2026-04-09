extends Resource
class_name Weapon

@export var name: String
@export var weapon_model: PackedScene
@export var auto_fire: bool = false

@export var hand_position: Vector3
@export var hand_rotation: Vector3

@export var weapon_idle_animation: Animation
@export var weapon_shoot_animation: Animation
@export var weapon_reload_animation: Animation
@export var weapon_change_animation: Animation

@export var current_ammo: Ammo
@export var reserve_ammo: Array[Ammo]
@export var max_ammo_clips: int = 2
@export var override_max_ammo: bool = false
@export var weapon_to_drop: PackedScene
