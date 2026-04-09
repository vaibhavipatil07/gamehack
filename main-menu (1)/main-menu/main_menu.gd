extends Control

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Connect the buttons to the functions below
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Optional: Automatically select the start button for keyboard/controller support
	start_button.grab_focus()

func _on_start_pressed() -> void:
	# Change this path to match exactly where your test_world.tscn is saved!
	get_tree().change_scene_to_file("res://test_world.tscn")

func _on_settings_pressed() -> void:
	print("Settings menu not built yet!")

func _on_quit_pressed() -> void:
	# This closes the entire game
	get_tree().quit()
