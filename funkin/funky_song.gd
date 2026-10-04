extends Song
class_name FunkySong

@export_file('*.res', '*.tres') var icons: String
@export var locked: bool = false

@export_group("Story Mode Stuff")
@export var dont_display_until_played: bool = false
