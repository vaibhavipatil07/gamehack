extends RigidBody3D
class_name RigidBodyBullet

@export var damage: float = 1.0

func _on_body_entered(_body: Node) -> void:
	queue_free()
