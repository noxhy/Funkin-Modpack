extends Node2D
class_name ResultNode

@export var hold_frame: int = 0

func _on_animate_symbol_2d_animation_looped() -> void:
	$AnimateSymbol2D.frame = hold_frame


func _on_animate_symbol_animation_looped() -> void:
	$AnimateSymbol.frame = hold_frame
