extends Control


@onready var start_button = $Start_Button as Button
@onready var options_button = $Opt_Button as Button
@onready var start_level = preload("res://Scenes/Locations/Game_scene.tscn") as PackedScene

func _ready():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_opt_pressed)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
		
func on_opt_pressed() -> void:
	get_tree().quit()
		
