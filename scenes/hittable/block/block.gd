class_name Block
extends Hittable


@export_group("Bump")
@export var bump_offset := 4.0
@export var bump_duration := 0.2

@onready var sprite: Sprite2D = $Sprite2D


func bump() -> void:
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + Vector2.UP * bump_offset, bump_duration / 2)
	tween.tween_property(self, "position", position, bump_duration / 2)
