extends CSGBox3D

var active_envelope: Node3D

@export var start_pos: Vector3
@export var end_pos: Vector3

@export var call_manager: Node3D

const lerp_speed = 4

func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.get_meta("envelope_id") != null and body.get_meta("stamp_value") != 0 and active_envelope == null):
		body.set_collision_layer_value(1,false)
		body.set_collision_layer_value(5,false)
		body.set_collision_mask_value(1,false)
		body.set_collision_mask_value(1,false)
		active_envelope = body
		active_envelope.position = start_pos
	pass # Replace with function body.


func _process(delta: float) -> void:
	if(active_envelope != null):
		active_envelope.position = lerp(active_envelope.position, end_pos, 4 * delta)
		if(active_envelope.position.distance_to(end_pos) < 0.1):
			var result = false
			if(active_envelope.get_meta("stamp_value") == 1):
				result = false
			else:
				result = true
			call_manager.receive_answer(active_envelope.get_meta("envelope_id"), result)
			active_envelope.queue_free()
			active_envelope = null;
