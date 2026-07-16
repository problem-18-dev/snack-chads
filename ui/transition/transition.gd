class_name Transition
extends Control

@export_group("Properties")
@export var duration := 4.0

@onready var duration_timer: Timer = $DurationTimer


func _ready() -> void:
	duration_timer.start(duration)


func _on_duration_timer_timeout() -> void:
	queue_free()
