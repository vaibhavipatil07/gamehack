extends CanvasLayer


func _on_camera_model_view_changed(view: bool) -> void:
	visible = !view
