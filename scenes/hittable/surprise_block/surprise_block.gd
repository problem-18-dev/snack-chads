class_name SurpriseBlock
extends Block


const DISABLED_TEXTURE: Texture2D = preload("uid://di1dn68pjqkh1")

@export var content_packed: PackedScene
@export var duration := 0.5

var _disabled := false
var _consumable: Consumable

@onready var content_destination_marker: Marker2D = $ContentDestinationMarker


func _ready() -> void:
	_prepare_content()


func bump() -> void:
	super()
	hit()


func hit() -> void:
	if _disabled:
		return
	
	_disabled = true
	
	sprite.texture = DISABLED_TEXTURE
	bump()
	_pop_content()


func _pop_content() -> void:
	if not _consumable:
		return
	
	get_parent().add_child(_consumable)
	
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(_consumable, "global_position", content_destination_marker.global_position, duration)
	tween.tween_callback(_consumable.start)
	await tween.finished
	_consumable = null


func _prepare_content() -> void:
	if not content_packed:
		return
	
	var consumable: Consumable = content_packed.instantiate()
	consumable.global_position = global_position
	_consumable = consumable
