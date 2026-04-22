class_name SurpriseBlock
extends AnimatableBody2D


const DISABLED_TEXTURE: Texture2D = preload("uid://di1dn68pjqkh1")


@export_group("Hit properties")
@export var hit_offset := 10.0
@export var hit_duration := 0.25

var _disabled := false

@onready var sprite: Sprite2D = $Sprite2D


func hit() -> void:
	_tween_hit()


func _tween_hit() -> void:
	if _disabled:
		return
	
	if OS.is_debug_build():
		Debug.log("Surprise block hit")
	
	_disabled = true
	
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + Vector2.UP * hit_offset, hit_duration / 2)
	tween.tween_property(sprite, "texture", DISABLED_TEXTURE, 0)
	tween.tween_property(self, "position", position, hit_duration / 2)
