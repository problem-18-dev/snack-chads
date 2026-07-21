@tool
extends MarginContainer

signal pressed

const HOVER_COLOR := Color(0.69, 0.663, 0.894, 1.0)
const PRESSED_COLOR := Color("fff7a0")

@export_group("Properties")
@export var button_text := "Play"

@onready var label: Label = $PrimaryButton/Label
@onready var primary_button: Button = $PrimaryButton


func _ready() -> void:
	label.text = button_text


func _on_primary_button_mouse_entered() -> void:
	label.add_theme_color_override("font_color", HOVER_COLOR)


func _on_primary_button_mouse_exited() -> void:
	label.remove_theme_color_override("font_color")


func _on_primary_button_button_up() -> void:
	_on_primary_button_mouse_entered()


func _on_primary_button_button_down() -> void:
	label.add_theme_color_override("font_color", PRESSED_COLOR)


func _on_primary_button_pressed() -> void:
	pressed.emit()
