extends AnimatableBody2D

const DARK_TEXTURE := preload("uid://g3325874vilu")
const LIGHT_TEXTURE := preload("uid://bekxxr844rl7o")

@export var dark := true

@onready var sprite: Node2D = $Sprite


func _ready() -> void:
	for sprite_instance: Sprite2D in sprite.get_children():
		sprite_instance.texture = DARK_TEXTURE if dark else LIGHT_TEXTURE
