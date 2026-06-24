extends OptionsSubmenu

func pressed_button(id: StringName):
	match id:
		&"offset":
			Global.change_scene_to("uid://bchoqkhsgg6rb")
			SoundManager.accept.play()
			SoundManager.music.stop()
		
		&"clear_save":
			SaveManager.instance = Save.new()
			SaveManager.flush()
			SoundManager.accept.play()
		
		_:
			printerr("No function assigned to: ", id)
