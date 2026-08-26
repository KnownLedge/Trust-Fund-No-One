extends Resource

#This resource is for storing a group of calls for the player to process as a collective
#These should have a set species behind them with a page giving rules for these species

class_name Call_Set

@export var info_page_texture: Texture

@export var calls: Array[CallerResource]
