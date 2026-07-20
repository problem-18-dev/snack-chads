extends Interactable

@export_group("Destination")
@export var enabled := false
@export var destination: Main.Scene
@export_group("Animation")
@export var direction := Vector2.DOWN
@export var distance := 30.0
@export var speed := 1.0

@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	_prepare()


func interact() -> void:
	if not enabled:
		return

	super()

	if debug_enabled:
		Debug.log("Player interacted with pipe")

	_snap_player()
	AudioManager.play_sfx(AudioManager.Sfx.PIPE)
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	var pipe_movement := _get_marker_position() + direction * distance
	tween.tween_property(_player, "global_position", pipe_movement, speed)
	await tween.finished
	_transfer()


func _prepare() -> void:
	detection_area.monitoring = enabled


func _transfer() -> void:
	assert(destination, "Pipe enabled, but no destination set.")
	GameState.save_player_mode(_player.player_mode)
	GameState.save_player_energy_time(_player.get_remaining_energy_time())
	GameState.set_return_point(GameState.ReturnPoint.PIPE)
	GameManager.main.load_scene(destination)


func _on_detection_area_body_entered(body: Player) -> void:
	_player = body
	_player.set_interactable(self)


func _on_detection_area_body_exited(body: Player) -> void:
	body.unset_interactable()
	_player = null
