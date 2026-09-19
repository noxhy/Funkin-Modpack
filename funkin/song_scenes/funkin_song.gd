extends BasicSong
class_name FunkinSong


@export var death_scene: PackedScene = load("uid://bd083xcqslcsd")
var current_death_scene = null
var particle_material: ParticleProcessMaterial = load("uid://bpe5oamr6s010")

func _ready() -> void:
	super()
	current_death_scene = death_scene.instantiate()
	Signals.connect(&"play_song_finished", self.finished)

func _process(delta: float) -> void:
	super(delta)


func note_hit(note: Note, lane: int, hit_time: float, strum_manager: StrumManager):
	get_tree().set_group(get_group_from_manager(strum_manager), "animation_prefix",
	&"mom_" if note.note_type == "mom" else &"")
	super(note, lane, hit_time, strum_manager)


func show_combo(rating: NoahStats.HIT_RATING, _combo: int):
	if playstate:
		var hit_rating: String
		
		match rating:
			NoahStats.HIT_RATING.SICK:
				hit_rating = "sick"
			
			NoahStats.HIT_RATING.GOOD:
				hit_rating = "good"
			
			NoahStats.HIT_RATING.BAD:
				hit_rating = "bad"
			
			NoahStats.HIT_RATING.SHIT:
				hit_rating = "shit"
			
			_:
				hit_rating = "miss"
		
		if rating != NoahStats.HIT_RATING.MISS:
			if playstate.song_stats.sicks == playstate.song_stats.total_notes:
				hit_rating = str("fc_", hit_rating)
		
		var rating_instance: GPUParticles2D = rating_node.instantiate()
		
		rating_instance.ui_skin = playstate.ui_skin
		rating_instance.animation = hit_rating
		rating_instance.z_index = 1000
		rating_instance.process_material = particle_material
		
		var add_numbers: Callable = func(parent: Node) -> void:
			if _combo > 9:
				var combo_string: String = str(_combo)
				var digits: int = combo_string.length()
				for digit in digits:
					var combo_number_instance: GPUParticles2D = combo_numbers_node.instantiate()
					
					combo_number_instance.position.x = playstate.ui_skin.numbers_spacing * (
						(digits - 1) / -2.0 + digit) * playstate.ui_skin.numbers_scale
					
					combo_number_instance.ui_skin = playstate.ui_skin
					if playstate.song_stats.max_combo == playstate.song_stats.total_notes:
						combo_number_instance.animation = str("fc_", combo_string[digit])
					else:
						combo_number_instance.animation = combo_string[digit]
					
					combo_number_instance.z_index = 1000
					combo_number_instance.process_material = particle_material
					
					parent.add_child(combo_number_instance)
		
		if SettingsManager.data.combo_ui and playstate.ui:
			if playstate.ui.rating_marker:
				playstate.ui.rating_marker.add_child(rating_instance)
			
			if playstate.ui.combo_marker:
				add_numbers.call(playstate.ui.combo_marker)
		else:
			if rating_marker:
				rating_marker.add_child(rating_instance)
			
			if combo_marker:
				add_numbers.call(combo_marker)


func died():
	if player:
		current_death_scene.player_position = player.global_position
		current_death_scene.player_scale = Vector2(player.scale.x, player.scale.y)
	
	current_death_scene.camera_zoom = playstate.camera.get_zoom()
	
	get_tree().change_scene_to_node(current_death_scene)


func finished():
	playstate.basic_event(0, "camera_position", [2])
