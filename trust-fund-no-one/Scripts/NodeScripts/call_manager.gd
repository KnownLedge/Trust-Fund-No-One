extends Node

@export var audio_player: AudioStreamPlayer3D

@export var printer_obj: Node3D

@export var call_resources: Array[CallerResource]

var call_progress = 0

func start_call(CallInfo: CallerResource):
	audio_player.stream = CallInfo.audio_track
	audio_player.play()
	printer_obj.start_translation(CallInfo.call_translation)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("NumpadOne")):
		start_call(call_resources[0])
	if(Input.is_action_just_pressed("NumpadTwo")):
		start_call(call_resources[1])
	if(Input.is_action_just_pressed("NumpadThree")):
		start_call(call_resources[2])
	if(audio_player.stream != null):
		call_progress = audio_player.get_playback_position() / audio_player.stream.get_length()
