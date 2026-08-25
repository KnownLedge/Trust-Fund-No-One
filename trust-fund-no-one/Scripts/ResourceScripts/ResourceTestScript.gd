class_name TesterResource
extends Resource

@export var AudioTrack: AudioStream
@export var TranslatedText: String

func _init(p_AudioTrack = null, p_TranslatedText = "") -> void:
	AudioTrack = p_AudioTrack
	TranslatedText = p_TranslatedText
