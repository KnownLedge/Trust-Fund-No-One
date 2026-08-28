extends Node3D

@export var audio_player: AudioStreamPlayer3D

@export var printer_obj: Node3D

@export var call_resources: Array[CallerResource]

@export var client_envelope: Node3D

@export var eject_pos: Vector3

const EJECT_SPEED = 6

var printing = false

var tracked_envelopes = 0

var printed_envelopes = 0

var call_progress = 0

func _ready() -> void:
	receive_call_group()


func print_envelope(delta: float):
	var new_envelope =  client_envelope.duplicate()
	get_parent().add_child(new_envelope)
	new_envelope.get_node("Label3D").text = "Client " + str(printed_envelopes + 1)
	new_envelope.global_position = global_position
	while(new_envelope.position.distance_to(eject_pos) > 0.1):
		new_envelope.global_position = lerp(new_envelope.global_position, eject_pos, EJECT_SPEED * delta)
		await get_tree().create_timer(0.1).timeout
	new_envelope.freeze = false
	new_envelope.get_node("CollisionShape3D").disabled = false
	printed_envelopes += 1
	

func receive_call_group():
	tracked_envelopes = -1
	printed_envelopes = 0
	printing = true

func start_call(CallInfo: CallerResource):
	audio_player.stream = CallInfo.audio_track
	audio_player.play()
	printer_obj.start_translation(CallInfo.call_translation)

func _process(delta: float) -> void:
	
	if(printing):
		if(tracked_envelopes < printed_envelopes):
			tracked_envelopes = printed_envelopes
			if(printed_envelopes < 3):
				print_envelope(delta)
				print("printing envelope")
			else:
				printing = false
	
	if(Input.is_action_just_pressed("NumpadOne")):
		start_call(call_resources[0])
	if(Input.is_action_just_pressed("NumpadTwo")):
		start_call(call_resources[1])
	if(Input.is_action_just_pressed("NumpadThree")):
		start_call(call_resources[2])
	if(audio_player.stream != null):
		call_progress = audio_player.get_playback_position() / audio_player.stream.get_length()
