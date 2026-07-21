class_name PointsComponent
extends Node2D

const SCENE := preload("uid://bor67w714f6wa")
const DEFAULT_DURATION := 0.75
const DEFAULT_RISE := 16.0

@export_group("Properties")
@export var duration := DEFAULT_DURATION
@export var rise := DEFAULT_RISE

@onready var label: Label = $Label


static func spawn(parent: Node, world_position: Vector2, amount: int) -> void:
	var popup: PointsComponent = SCENE.instantiate()
	parent.add_child(popup)
	popup.global_position = world_position
	popup.play(amount)


func play(amount: int) -> void:
	label.text = str(amount)

	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector2(0, -rise), duration)
	tween.tween_property(label, "modulate:a", 0.25, duration)
	tween.chain().tween_callback(queue_free)
