extends Control

@export var call_manager: Node3D

#func _on_button_mouse_entered() -> void:
	#print("NOT gaming on the computer")
	#pass # Replace with function body.


func _on_caller_button_one_pressed() -> void:
	
	call_manager.take_call(0)
	pass # Replace with function body.


func _on_caller_button_two_pressed() -> void:
	call_manager.take_call(1)
	pass # Replace with function body.


func _on_caller_button_three_pressed() -> void:
	call_manager.take_call(2)
	pass # Replace with function body.
