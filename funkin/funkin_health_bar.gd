extends TextureProgressBar

@onready var icon_manager = $Icons
@onready var player_icon = $Icons/Player
@onready var enemy_icon = $Icons/Enemy

## Whether the bar should be smooth
var smooth: bool = true

## Used when smooth is true
var smooth_speed: float = 25.0

var intended_value: float = 0

var pixel: bool = false :
	set(v):
		var filter = TEXTURE_FILTER_NEAREST if v else TEXTURE_FILTER_PARENT_NODE
		
		player_icon.texture_filter = filter
		enemy_icon.texture_filter = filter
		pixel = v

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.play_health_changed.connect(on_health_change)
	Signals.play_conductor_beat_hit.connect(on_beat)

	if is_inside_tree():
		var ps: PlayState = get_tree().get_first_node_in_group(&"playstate")
		if ps:
			min_value = ps.health_min
			max_value = ps.health_max
			value = ps.health
	
	intended_value = value
	
	if SettingsManager.data.downscroll:
		position.y *= -1

func on_health_change(v: float, d: float):
	if smooth:
		intended_value = v
	else:
		value = v

	var conditions = [
		[v >= max_value * 0.8, "winning", "losing"],
		[v <= max_value * 0.2, "losing", "winning"],
		[true, "default", "default"]
	]
	
	for condition in conditions:
		if condition[0]:
			if player_icon.sprite_frames:
				if player_icon.sprite_frames.get_animation_names().has(condition[1]):
					player_icon.play(condition[1])
			
			if enemy_icon.sprite_frames:
				if enemy_icon.sprite_frames.get_animation_names().has(condition[2]):
					enemy_icon.play(condition[2])
			
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if smooth:
		value = lerpf(value, intended_value, 1.0 - exp(-delta * smooth_speed))

	var display_x: float = (value / max_value) * size.x
	display_x = size.x - display_x
	
	icon_manager.position = Vector2(display_x, 10)

func on_beat(current_beat: int, measure_relative: int):
	var time: float = GameManager.conductor.seconds_per_step * 2 / GameManager.conductor.stream_player.pitch_scale
	
	Global.bop_tween(player_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)
	Global.bop_tween(enemy_icon, "scale", Vector2(0.8, 0.8), Vector2(0.9, 0.9), time, Tween.TRANS_QUAD)


func set_player_icons(icons: SpriteFrames):
	player_icon.frames = icons


func set_enemy_icons(icons: SpriteFrames):
	enemy_icon.frames = icons


func set_player_color(color: Color):
	tint_progress = color


func set_enemy_color(color: Color):
	tint_under = color
