extends Node3D

@export var head: Node3D
@export var camera: Camera3D

const SENSITIVITY = 0.005

const HAND_RETURN = 3

const HAND_EXTEND = 2

const LEFT_TURN = 12.5

const RIGHT_TURN = -12.5

const STRAFE_SPEED = 0.2

@export var cursor_ui: TextureRect

@export var grab_texture: Texture

@export var computer_texture: Texture

@export var left_hand: Node3D

@export var right_hand: Node3D

@export var ray: RayCast3D

@export var UI_ray: RayCast3D

@export var left_ray: RayCast3D

@export var right_ray: RayCast3D

@export var default_left_hold: Vector3

@export var default_right_hold: Vector3

@export var left_limit:float = 3

@export var right_limit:float = 3

@export var zoom_out_limit = 75

@export var zoom_in_limit = 20

@export var zoom_increment = 10;

var strafe_pos = 0

var default_pos: Vector3

var left_item: Node3D

var right_item: Node3D

var left_hold_pos: Vector3

var right_hold_pos: Vector3

var left_hover_pos: Vector3

var right_hover_pos: Vector3

enum holdType {PAPER, STAPLER}
var left_hold_type: holdType
var right_hold_type: holdType
#This enum may go unused

@export var pc_top_Left_node:Node3D
@export var pc_bottom_right_node:Node3D
@export var subViewport:SubViewport

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	left_hover_pos = left_hand.position
	right_hover_pos = right_hand.position
	default_pos = position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(60))


func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
	if(Input.is_action_just_pressed("LeftDrop")):
		drop_item(left_hand, left_item,left_hover_pos,left_ray)
		left_item = null
	if(Input.is_action_just_pressed("RightDrop")):
		drop_item(right_hand, right_item, right_hover_pos,right_ray)
		right_item = null
		
	left_ray.target_position = left_hand.position
	
	right_ray.target_position = right_hand.position
	
	if(Input.is_action_just_released("MouseScrollUp")):
		camera.fov = clampf(camera.fov - zoom_increment, zoom_in_limit, zoom_out_limit)
		print("zooming")
	
	if(Input.is_action_just_released("MouseScrollDown")):
		camera.fov = clampf(camera.fov + zoom_increment, zoom_in_limit, zoom_out_limit)
		print("zoming")


func drop_item(hand, hand_item:Node3D, hover_pos, hand_ray:RayCast3D):
	if(hand_item != null):
		hand_item.reparent(get_parent())
		if(hand_item is RigidBody3D):
			hand_item.freeze = false
		if(hand_ray.is_colliding()):
			hand_item.global_position = hand_ray.get_collision_point()
		hand_item.translate(Vector3(0,0.3,0))
		
		
		hand_item = null
		hand.position = hover_pos

func _physics_process(delta: float) -> void:
	
	if (left_item == null && right_item == null && UI_ray.is_colliding()):
		#print("trying to click")
		var hitPoint = UI_ray.get_collision_point()
		if(not ray.is_colliding()):
			cursor_ui.texture = computer_texture
		var uiX = inverse_lerp(pc_top_Left_node.global_position.x, pc_bottom_right_node.global_position.x, hitPoint.x)
		var uiY = inverse_lerp(pc_top_Left_node.global_position.y, pc_bottom_right_node.global_position.y, hitPoint.y)
		var simMousePos = Vector2(uiX * subViewport.size.x, uiY * subViewport.size.y)
		var mouse_event = InputEventMouseButton.new()
		mouse_event.position = simMousePos
		mouse_event.pressed = Input.is_action_just_pressed("LeftClick")
		mouse_event.button_index = MOUSE_BUTTON_LEFT
		mouse_event.button_mask - MOUSE_BUTTON_MASK_LEFT
		subViewport.push_input(mouse_event)
	else:
		cursor_ui.texture = grab_texture
	
	
	if(Input.is_action_just_pressed("LeftClick")):
		if(left_item == null and ray.is_colliding() and right_item != ray.get_collider()):
			#print("picking up thing")
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
			
		
			
		#else:
			#print("not picking thing up")
	elif(Input.is_action_pressed("LeftClick") and not UI_ray.is_colliding()):#checking for held input
		left_hand.position = lerp(left_hand.position, left_hold_pos, delta * HAND_EXTEND)
	else: 
		left_hand.position = lerp(left_hand.position, left_hover_pos, delta * HAND_RETURN)
		if(left_hand.position.distance_to(left_hover_pos) < 2):
			left_hold_pos = default_left_hold
	
	if(left_ray.is_colliding() and left_ray.get_collider() != left_item):
		left_hand.global_position = left_ray.get_collision_point()
		left_hand.position = lerp(left_hand.position, left_hover_pos, delta * HAND_RETURN)
	
	
	
	#Ideally left and right hand would share code through functions to speed up bug fixing, but i wanna risk avoiding the headache of doing that to save time
	#so this should be the same code as above, but for the right hand
	
	if(Input.is_action_just_pressed("RightClick")):
		if(right_item == null and ray.is_colliding()and left_item != ray.get_collider()):
			#print("picking up thing")
			right_hand.global_position = ray.get_collision_point()
			right_hold_pos = right_hand.position
			if(true):#ray.get_collider() is CSGBox3D):
				print(ray.get_collider().name)
				right_item = ray.get_collider()
			else:
				print(ray.get_collider().get_parent_node().name)
				right_item = ray.get_collider().get_parent_node()
			if(right_item is RigidBody3D):
				right_item.freeze = true
			
			right_item.reparent(right_hand)
			
			if(right_item.get_meta("hold_rotation")):
				right_item.rotation_degrees = right_item.get_meta("hold_rotation")
			
			right_item.rotate_y(deg_to_rad(RIGHT_TURN))
			
			
		#else:
			#print("not picking thing up")
	elif(Input.is_action_pressed("RightClick") and not UI_ray.is_colliding()):#checking for held input
		right_hand.position = lerp(right_hand.position, right_hold_pos, delta * HAND_EXTEND)
	else: 
		right_hand.position = lerp(right_hand.position, right_hover_pos, delta * HAND_RETURN)
		if(right_hand.position.distance_to(right_hover_pos) < 2):
			right_hold_pos = default_right_hold
	
	if(right_ray.is_colliding() and right_ray.get_collider() != right_item):
		right_hand.global_position = right_ray.get_collision_point()
		right_hand.position = lerp(right_hand.position, right_hover_pos, delta * HAND_RETURN)
	
	#Strafing
	if(Input.is_action_pressed("StrafeLeft")):
		strafe_pos = clampf(strafe_pos - STRAFE_SPEED,-right_limit, left_limit)
		position = default_pos + Vector3(strafe_pos,0,0)
	if(Input.is_action_pressed("StrafeRight")):
		strafe_pos = clampf(strafe_pos + STRAFE_SPEED,-right_limit, left_limit)
		position = default_pos + Vector3(strafe_pos,0,0)
