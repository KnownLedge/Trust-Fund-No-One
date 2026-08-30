extends Node

@export var call_manager: Node3D

@export var paper_obj: Node3D

@export var paper_spawn_pos: Vector3

@export var paper_print_pos: Vector3

@export var paper_eject_force: Vector3

@export var char_limit = 450

var text_to_print:String

var current_paper: Node3D

var current_paper_text: Label3D

var is_active: bool = false

var string_pos = 0

var cutoff_call_prog = 0

func start_translation(printedText):
	if(current_paper != null):
		eject_paper()
	print("translating")
	if(printedText != null):
		text_to_print = printedText
	current_paper = paper_obj.duplicate()
	get_parent().add_child(current_paper)
	current_paper.position = paper_spawn_pos
	current_paper_text = current_paper.get_node("Label3D")
	current_paper_text.text = ""
	is_active = true
	

func _process(delta: float) -> void:
	if(is_active):
		current_paper.position = lerp(current_paper.position, paper_print_pos, 6 * delta)
		while((call_manager.call_progress - cutoff_call_prog) > get_page_progress() and string_pos < text_to_print.length()):
			current_paper_text.text = current_paper_text.text.insert(string_pos, text_to_print[string_pos])
			#print("inserted text")
			string_pos = string_pos + 1
		
		
		if(call_manager.call_progress == 0 and string_pos > 0):
			is_active = false
			eject_paper()
		elif(current_paper_text.text.length() > char_limit):
			safe_eject_paper()
			#text_to_print = text_to_print.substr(string_pos)
			cutoff_call_prog = call_manager.call_progress
			
			start_translation(null)
		#print("call progress " + str(call_manager.call_progress) + "print progress " + str(get_page_progress()))

func safe_eject_paper():
	current_paper.position = paper_print_pos
	current_paper.get_node("CollisionShape3D").disabled = false
	current_paper.freeze = false
	current_paper.apply_central_force(paper_eject_force)
	current_paper = null
	current_paper_text = null

func eject_paper():
	string_pos = 0
	current_paper.position = paper_print_pos
	current_paper.get_node("CollisionShape3D").disabled = false
	current_paper.freeze = false
	current_paper.apply_central_force(paper_eject_force)
	current_paper = null
	current_paper_text = null
	cutoff_call_prog = 0

func get_page_progress():
	return float(current_paper_text.text.length()) / float(text_to_print.length())
