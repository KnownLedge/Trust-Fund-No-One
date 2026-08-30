extends RigidBody3D

var call_manager: Node3D

var unique_id = 0

@export var reset_height = 3

func _process(delta: float) -> void:
	if(global_position.y < 3 and call_manager != null):
		if(call_manager.printing == false):
			call_manager.printed_envelopes = unique_id - 1
			call_manager.print_envelope()
			queue_free()
