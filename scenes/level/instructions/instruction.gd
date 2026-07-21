@tool
extends Control

@export_group("Properties")
@export_multiline var text: String

@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
