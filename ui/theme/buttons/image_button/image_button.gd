@tool
extends MarginContainer

signal pressed

@export_group("Properties")
@export var image: Texture2D

@onready var texture_rect: TextureRect = $ImageButton/TextureRect


func _ready() -> void:
	texture_rect.texture = image


func _on_image_button_pressed() -> void:
	pressed.emit()
