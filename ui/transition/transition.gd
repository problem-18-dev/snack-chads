class_name Transition
extends CanvasLayer

@export_group("Properties")
@export var level_title: String

@onready var title: Label = %Title


func _ready() -> void:
	title.text = level_title
