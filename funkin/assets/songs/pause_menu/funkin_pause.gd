extends Node

## Dictionary of pages of options
var pages: Dictionary[StringName, Array] = {
	&"default": [&"Resume", &"Options", &"Restart", &"Change Difficulty", &"Exit"],
	&"charting": [&"Resume", &"Options", &"Restart", &"Return to editor"],
	&"difficulties": [&'Back']
}

## Scene to enter when exiting
var exit_scene: String = Constants.FREEPLAY_MENU_SCENE

## The current loaded page from [member pages]
var cur_page: Array = []

## The current index within [member cur_page]
var cur_selected: int = 0

var option_nodes: Array[Node] = []

var changing_difficulty: bool = false

var current_credit: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if GameManager.current_song:
		if GameManager.current_song.difficulties.is_empty():
			pages.get(&"default").remove_at(pages.get(&"default").find(&"Change Difficulty"))
		
		for difficulty in GameManager.current_song.difficulties:
			pages.difficulties.append(difficulty)
	else:
		pages.get(&"default").remove_at(pages.get(&"default").find(&"Change Difficulty"))
		
	match GameManager.play_mode:
		GameManager.PLAY_MODE.CHARTING:
			load_page(&"charting")
		_:
			load_page(&"default")
	
	change_selection(cur_selected)
	
	
	if GameManager.current_song:
		%"Song Name".text = GameManager.current_song.title
		%"Other Info".text = str(GameManager.deaths, " Blue balls")
		display_credits()
		current_credit += 1
	
	$AnimationPlayer.play("intro")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var axis = Global.get_input_axis_just_pressed(&"menu_down", &"menu_up")
	
	if axis:
		change_selection(cur_selected - axis)
	if Input.is_action_just_pressed(&"menu_cancel") or Input.is_action_just_pressed(&"menu_accept"):
		select_option(cur_selected)


func load_page(page: String):
	for node in option_nodes:
		node.queue_free()
	
	option_nodes.clear()
	
	cur_page = pages.get(page)
	
	for i in cur_page:
		var menu_option_instance = load("uid://55odtbd2v2ql").instantiate()
		
		menu_option_instance.position = Vector2(45, 300)
		menu_option_instance.text = i.to_upper()
		
		add_child(menu_option_instance)
		menu_option_instance.label.forced_anim_suffix = &" bold"
		option_nodes.append(menu_option_instance)

## Changes selection directly to a given key
func change_selection(i: int):
	SoundManager.scroll.play()
	
	cur_selected = wrapi(i, 0, cur_page.size())
	
	var index = -cur_selected
	
	var tween = create_tween()
	tween.set_parallel(true)
	for j in option_nodes:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		var node_position = Vector2(45 + (25 * index), 300 + index * 175)
		tween.tween_property(j, "position", node_position, 0.25)
		j.modulate = Color(0.5, 0.5, 0.5)
		index += 1
	
	option_nodes[cur_selected].modulate = Color(1, 1, 1)

func select_option(i: int):
	var option = cur_page[i]
	
	match option.to_lower():
		&"resume": resume()
		&"options": open_options_menu()
		&"restart": restart()
		&"exit": exit_menu()
		&"return to editor": open_chart_editor()
		
		&"change difficulty":
			load_page(&"difficulties")
			change_selection(0)
			changing_difficulty = true
		
		&"back":
			load_page(&"default")
			change_selection(0)
			changing_difficulty = false
		_:
			if changing_difficulty:
				change_difficulty(option)

func resume() -> void:
	get_tree().paused = false
	Signals.play_unpaused.emit()
	queue_free()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func open_options_menu() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	Global.change_scene_to(Constants.OPTIONS_MENU_SCENE)

func exit_menu() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	GameManager.reset_stats()
	Global.change_scene_to(exit_scene)

func open_chart_editor() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	GameManager.reset_stats()
	Global.change_scene_to(Constants.CHART_EDITOR_SCENE)

func change_difficulty(difficulty: String):
	GameManager.difficulty = difficulty
	GameManager.deaths = 0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_timer_timeout() -> void:
	if not GameManager.current_song:
		return
	var time: float = 0.5
	
	var tween = create_tween()
	tween.tween_property(%Credits, "modulate", Color.TRANSPARENT, time)
	tween.tween_property(%Credits, "modulate", Color.WHITE, 1).set_delay(time)
	
	await get_tree().create_timer(time).timeout
	
	display_credits()
	current_credit += 1

func display_credits():
	if current_credit % 2 == 0:
		%Credits.text = str("Artist: ", GameManager.current_song.artist)
	else:
		%Credits.text = str("Charter: ", GameManager.current_song.charter)
