extends Resource
class_name CallerResource

@export var is_scam: bool

@export var audio_track: AudioStream

@export_multiline var call_translation: String

@export var translation_speed: Curve

func _init(p_isScam = false, p_AudioTrack = null, p_CallTranslation = "Proof", p_TranslationSpeed = Curve.new()) -> void:
	is_scam = p_isScam
	audio_track = p_AudioTrack
	call_translation = p_CallTranslation
	translation_speed = p_TranslationSpeed
	translation_speed.add_point(Vector2(0,0),0,0,Curve.TANGENT_LINEAR,Curve.TANGENT_LINEAR)
