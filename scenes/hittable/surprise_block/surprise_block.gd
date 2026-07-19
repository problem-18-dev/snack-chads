class_name SurpriseBlock
extends Block

@export var content_packed: PackedScene
@export var duration := 0.5

var _disabled := false
var _content: Node2D

@onready var content_destination_marker: Marker2D = $ContentDestinationMarker


func _ready() -> void:
	super()
	_prepare_content()


func bump() -> void:
	super()
	hit()


func hit() -> void:
	if _disabled:
		return

	_disabled = true

	sprite.play("disabled")
	bump()
	_pop_content()


func _pop_content() -> void:
	if not _content:
		return

	get_parent().add_child(_content)

	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(_content, "global_position", content_destination_marker.global_position, duration)
	tween.tween_callback(_content.start)
	await tween.finished
	_content = null


func _prepare_content() -> void:
	if not content_packed:
		content_destination_marker.hide()
		return

	var content = content_packed.instantiate()
	content.global_position = global_position
	_content = content
