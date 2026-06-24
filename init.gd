extends Node

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	Preload.character_data["boyfriend"] = load("uid://bkhhp2v4u756o")
	Preload.character_data["pico"] = load("uid://dskdxvwa3xf5t")
	
	GameManager.current_character = "boyfriend"
	GameManager.character = Preload.character_data.get(GameManager.current_character)
	
	SoundManager.music.stream = load("uid://du4qr2rxqjkw")
	SoundManager.accept.stream = load("uid://guk2nlj2xwt7")
	SoundManager.cancel.stream = load("uid://dyy2yik0yf60r")
	SoundManager.scroll.stream = load("uid://svn606p6k0w0")
	
	var miss_sound: AudioStreamRandomizer = AudioStreamRandomizer.new()
	miss_sound.streams_count = 3
	miss_sound.add_stream(0, load("uid://bmggbtser1g3u"))
	miss_sound.add_stream(1, load("uid://cfnrxgladhi2w"))
	miss_sound.add_stream(2, load("uid://cqne25yeqb7op"))
	
	SoundManager.miss.stream = miss_sound
	SoundManager.anti_spam.stream = miss_sound
	SoundManager.anti_spam.volume_db = -8
	
	DisplayServer.set_icon(load("uid://b6tvkvdbdai2u").get_image())
	
	Constants.set_script(preload("uid://osy8erwmdopi"))
	Global.change_scene_to(Constants.START_MENU_SCENE, null, false)
