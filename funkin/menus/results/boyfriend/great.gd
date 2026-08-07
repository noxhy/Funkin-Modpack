extends ResultNode

@export var hold_frame_2: int = 0


func _on_animate_symbol_2_animation_looped() -> void:
	$AnimateSymbol2.frame = hold_frame_2
