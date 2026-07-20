class_name FlickerComponent
extends Node2D

const DEFAULT_FLICKER_DURATION := 1.5

@export_group("Properties")
@export var flicker_target: Node2D
@export var flicker_duration := DEFAULT_FLICKER_DURATION


func _ready() -> void:
	flicker_target.show()


func flicker(duration := flicker_duration) -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(flicker_target, "visible", false, 0.05)
	tween.tween_property(flicker_target, "visible", true, 0.05)
	await get_tree().create_timer(duration).timeout
	tween.kill()
	flicker_target.show()
