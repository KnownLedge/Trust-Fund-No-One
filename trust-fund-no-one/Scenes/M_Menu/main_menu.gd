extends Control


@onready var start_button = $Start_Button as Button
@onready var options_button = $Opt_Button as Button
@onready var start_level = preload("res://Scenes/Locations/Test_Scene.tscn") as PackedScene

func _ready():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_opt_pressed)
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
		
func on_opt_pressed() -> void:
	get_tree().quit()
		
