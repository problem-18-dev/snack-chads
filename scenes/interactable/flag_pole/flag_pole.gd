extends Interactable

const MAX_HEIGHT := 120.0

@export_group("Properties")
@export var slide_duration := 1.0
@export_group("Store")
@export var store: Store
@export var delay_before_store := 2.0

@onready var bottom_marker: Marker2D = $BottomMarker2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func interact() -> void:
	super()

	if debug_enabled:
		Debug.log("Player interacted with flag pole")

	var player_position := to_local(_player.global_position)
	var snap_height := maxf(player_position.y, -MAX_HEIGHT)
	var snap_position := Vector2(-8.0, snap_height)
	_adjust_marker(snap_position)
	await _snap_player()
	_tween_and_finish()


func _tween_and_finish() -> void:
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_parallel()
	tween.tween_property(_player, "global_position", bottom_marker.global_position, slide_duration)
	tween.tween_callback(animation_player.play.bind("flag_down"))
	var end_destination := store.get_destination_global_position()
	tween.chain().tween_callback(_player.walk_to.bind(end_destination)).set_delay(delay_before_store)


func _on_detection_area_body_entered(body: Player) -> void:
	_player = body
	_player.set_interactable(self)
	_player.attempt_interaction()


func _on_detection_area_body_exited(body: Player) -> void:
	body.unset_interactable()
	_player = null
