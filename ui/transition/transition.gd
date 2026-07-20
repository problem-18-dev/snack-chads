class_name Transition
extends Control

@export_group("Properties")
@export var duration := 4.0
@export var level_title: String

@onready var duration_timer: Timer = $DurationTimer
@onready var next_level_label: Label = $MarginContainer/NextLevelLabel


func _ready() -> void:
	duration_timer.start(duration)
	next_level_label.text = level_title


func _on_duration_timer_timeout() -> void:
	hide()
