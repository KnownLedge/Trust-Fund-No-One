extends Node3D

@export var head: Node3D
@export var camera: Camera3D

const SENSITIVITY = 0.005

const HAND_RETURN = 3

const HAND_EXTEND = 2

const LEFT_TURN = 7.5

@export var left_hand: Node3D

@export var ray: RayCast3D

@export var default_left_hold: Vector3

var left_item: Node3D

var left_hold_pos: Vector3

var left_hover_pos: Vector3



enum holdType {PAPER, STAPLER}
var left_hold_type: holdType

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	left_hover_pos = left_hand.position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
	if(Input.is_action_just_pressed("LeftDrop")):
		left_item.reparent(get_parent())
		if(left_item is RigidBody3D):
			left_item.freeze = false
			
		left_item = null
		left_hand.position = left_hover_pos



func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("LeftClick")):
		if(left_item == null and ray.is_colliding()):
			print("picking up thing")
			left_hand.global_position = ray.get_collision_point()
			left_hold_pos = left_hand.position
			if(true):#ray.get_collider() is CSGBox3D):
				print(ray.get_collider().name)
				left_item = ray.get_collider()
			else:
				print(ray.get_collider().get_parent_node().name)
				left_item = ray.get_collider().get_parent_node()
			if(left_item is RigidBody3D):
				left_item.freeze = true
			

			
			
			left_item.reparent(left_hand)
			
			if(left_item.get_meta("hold_rotation")):
				left_item.rotation_degrees = left_item.get_meta("hold_rotation")
			
			left_item.rotate_y(deg_to_rad(LEFT_TURN))
			
			
		else:
			print("not picking thing up")
	elif(Input.is_action_pressed("LeftClick")):#checking for held input
		left_hand.position = lerp(left_hand.position, left_hold_pos, delta * HAND_EXTEND)
	elif(left_item != null): 
		left_hand.position = lerp(left_hand.position, left_hover_pos, delta * HAND_RETURN)
		if(left_hand.position.distance_to(left_hover_pos) < 2):
			left_hold_pos = default_left_hold
