extends Control

@onready var reason_label: Label = $CenterContainer/Panel/VBox/ReasonLabel
@onready var retry_button: Button = $CenterContainer/Panel/VBox/RetryButton
@onready var main_menu_button: Button = $CenterContainer/Panel/VBox/MainMenuButton

func _ready() -> void:
	# Start completely invisible
	modulate.a = 0.0
	
	# Create a smooth fade-in effect over 1.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# Connect the buttons to their functions via code
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

# You can call this from GameManager when the player dies
func set_reason(text: String) -> void:
	reason_label.text = text

func _on_retry_pressed() -> void:
	print("Restarting level...")
	# Once your game is built, you will uncomment this line:
	# GameManager.load_level(GameManager.current_level)

func _on_main_menu_pressed() -> void:
	print("Going to Main Menu...")
	# Once you build a main menu, you will uncomment this line:
	# get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
