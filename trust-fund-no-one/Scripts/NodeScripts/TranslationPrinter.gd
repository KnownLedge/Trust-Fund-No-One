extends Node

@export var call_manager: Node3D

@export var paper_obj: Node3D

@export var paper_spawn_pos: Vector3

var text_to_print:String

var current_paper: Node3D

var current_paper_text: Label3D

var is_active: bool = false

var string_pos = 0

func start_translation(printedText):
	print("translating")
	text_to_print = printedText
	current_paper = paper_obj.duplicate()
	add_child(current_paper)
	current_paper.position = paper_spawn_pos
	current_paper_text = current_paper.get_node("Label3D")
	current_paper_text.text = ""
	is_active = true
	

func _process(delta: float) -> void:
	if(is_active):
		while(call_manager.call_progress > get_page_progress() and string_pos < text_to_print.length()):
			current_paper_text.text = current_paper_text.text.insert(string_pos, text_to_print[string_pos])
			print("inserted text")
			string_pos = string_pos + 1
		
		if(call_manager.call_progress >= 1):
			is_active = false
			current_paper.position = Vector3(4,3,4)
		
		print("call progress " + str(call_manager.call_progress) + "print progress " + str(get_page_progress()))


func get_page_progress():
	return float(current_paper_text.text.length()) / float(text_to_print.length())
