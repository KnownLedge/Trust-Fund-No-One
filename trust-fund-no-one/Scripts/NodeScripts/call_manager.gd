extends Node3D

@export var audio_player: AudioStreamPlayer3D

@export var printer_obj: Node3D

@export var call_sets: Array[Call_Set]

@export var call_resources: Array[CallerResource]

@export var instruction_papers: Array[Node3D]

@export var client_envelope: Node3D

@export var instruction_paper: Node3D

@export var win_paper: Node3D

@export var lose_paper: Node3D

@export var eject_pos: Vector3

@export var starting_call_set: int = 1

@export var fade_out: ColorRect

const EJECT_SPEED = 6

var printing = false

var tracked_envelopes = 0

var printed_envelopes = 0

var printed_info = false

var call_progress = 0

var answers: Array[bool] = [false,false,false]

var call_failed = false

var envelopes_received = 0

func _ready() -> void:
	if(game_progress.current_call_set != 0):
		starting_call_set = game_progress.current_call_set
	apply_call_set(call_sets[starting_call_set - 1])
	receive_call_group()


func print_envelope():
	var new_envelope =  client_envelope.duplicate()
	get_parent().add_child(new_envelope)
	new_envelope.get_node("Label3D").text = "Client " + str(printed_envelopes + 1)
	new_envelope.set_meta("envelope_id", printed_envelopes + 1)
	new_envelope.global_position = global_position
	new_envelope.call_manager = self
	new_envelope.unique_id = printed_envelopes + 1
	while(new_envelope.position.distance_to(eject_pos) > 0.1):
		new_envelope.global_position = lerp(new_envelope.global_position, eject_pos, EJECT_SPEED * 0.03)
		await get_tree().create_timer(0.1).timeout
	new_envelope.freeze = false
	new_envelope.get_node("CollisionShape3D").disabled = false
	printed_envelopes += 1
	

func print_info():
	var new_info =  instruction_paper.duplicate()
	get_parent().add_child(new_info)
	#new_info.change_texture(call_sets[starting_call_set - 1].info_page_texture)
	new_info.global_position = global_position
	while(new_info.position.distance_to(eject_pos) > 0.1):
		new_info.global_position = lerp(new_info.global_position, eject_pos, EJECT_SPEED * 0.1)
		await get_tree().create_timer(0.1).timeout
	new_info.freeze = false
	new_info.get_node("CollisionShape3D").disabled = false
	printed_info = true


func apply_call_set(call_set: Call_Set):
	call_resources[0] = call_set.calls[0]
	call_resources[1] = call_set.calls[1]
	call_resources[2] = call_set.calls[2]
	instruction_paper = instruction_papers[starting_call_set - 1]

func receive_answer(answer_id: int, answer_result: bool):
	if(call_resources[answer_id - 1].is_scam != answer_result):
		call_failed = true
		print("CALL FAILED")
	envelopes_received += 1
	if(envelopes_received == 3):
		print("CALL DONE")
		if(call_failed):
			print("BOO YOU SUCK")
			end_day(false)
		else:
			print("god gamer")
			end_day(true)


func receive_call_group():
	tracked_envelopes = -1
	printed_envelopes = 0
	printing = true

func start_call(CallInfo: CallerResource):
	audio_player.stream = CallInfo.audio_track
	audio_player.play()
	printer_obj.start_translation(CallInfo.call_translation)

func take_call(call_id):
	start_call(call_resources[call_id])

func end_day(iswinner:bool):
	game_progress.current_call_set += 1
	#Print reward here, then delay with a screen fade out
	if(iswinner):
		instruction_paper = win_paper
	else:
		instruction_paper = lose_paper
	print_info()
	fade_transition()
	await get_tree().create_timer(5).timeout
	if(game_progress.current_call_set > call_sets.size()):
		game_progress.current_call_set = 0
		get_tree().change_scene_to_file("res://Scenes/M_Menu/main_menu.tscn")
		#get_tree().unload_current_scene()
	else:
		get_tree().reload_current_scene()
	#Change this to game scene

func fade_transition():
	fade_out.color.a - 0.01
	await get_tree().create_timer(0.05).timeout

func _process(delta: float) -> void:
	
	if(printing):
		if(true):
			if(tracked_envelopes < printed_envelopes):
				tracked_envelopes = printed_envelopes
				if(printed_envelopes < 3):
					print_envelope()
					print("printing envelope")
				else:
					print_info()
					printing = false
	
	if(Input.is_action_just_pressed("NumpadOne")):
		start_call(call_resources[0])
	if(Input.is_action_just_pressed("NumpadTwo")):
		start_call(call_resources[1])
	if(Input.is_action_just_pressed("NumpadThree")):
		start_call(call_resources[2])
	if(audio_player.stream != null):
		call_progress = audio_player.get_playback_position() / audio_player.stream.get_length()
