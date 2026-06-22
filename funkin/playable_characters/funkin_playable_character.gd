extends PlayableCharacter
class_name FunkinPlayableCharacter

@export_subgroup("Freeplay")
@export_file var dj: String
@export var background: Texture
@export_category("Results")
@export var result_songs: Dictionary[String, String]
@export_file('*.ogg', '*.wav', '*.mp3') var normal_intro: String
@export_file('*.ogg', '*.wav', '*.mp3') var loss_intro: String
@export var result_nodes: Dictionary[String, String] = {}
