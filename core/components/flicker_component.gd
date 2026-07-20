class_name FlickerComponent
extends Node2D

const DEFAULT_FLICKER_DURATION := 1.5

@export_group("Properties")
@export var flicker_target: Node2D
@export var flicker_duration := DEFAULT_FLICKER_DURATION

var _flicker_tween: Tween


func _ready() -> void:
	flicker_target.show()


func flicker(duration := flicker_duration) -> void:
	_flicker_tween = create_tween().set_loops()
	_flicker_tween.tween_property(flicker_target, "visible", false, 0.05)
	_flicker_tween.tween_property(flicker_target, "visible", true, 0.05)
	await get_tree().create_timer(duration).timeout
	_flicker_tween.kill()
	flicker_target.show()


func is_flickering() -> bool:
	return _flicker_tween and _flicker_tween.is_valid() and _flicker_tween.is_running()
