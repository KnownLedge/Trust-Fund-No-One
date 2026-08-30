extends RigidBody3D

@export var stamp_sprite: Sprite3D

@export var stamp_hitbox: Node3D

@export var stamp_value: int

var default_pos: Vector3
var default_rot: Vector3

const COOLDOWN = 1

var cooldown_timer = 0

func _ready() -> void:
	default_pos = global_position
	default_rot = global_rotation



func _process(delta: float) -> void:
	cooldown_timer -= delta
	if(global_position.y < -1 and freeze == false):
		global_position = default_pos
		global_rotation = default_rot

func _on_body_entered(body: Node) -> void:

	pass # Replace with function body.


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:

	pass # Replace with function body.


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(cooldown_timer < 0 and body.get_meta("stamp_value") != null):
		var new_stamp = stamp_sprite.duplicate()
		for child in body.get_children():
			if child.get_meta("is_stamp") != null:
				print("THERE IS ANOTHER STAMP, HELP")
				child.queue_free()
		body.add_child(new_stamp)
		new_stamp.global_position = stamp_hitbox.global_position
		new_stamp.translate(Vector3(0,-0.1,0))
		#new_stamp.rotate_x(deg_to_rad(90))
		new_stamp.scale = Vector3(0.25,0.25,0.25)
		body.set_meta("stamp_value", stamp_value)
		
		new_stamp.visible = true
		cooldown_timer = COOLDOWN
	pass # Replace with function body.
