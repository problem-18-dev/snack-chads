class_name HUD
extends CanvasLayer

signal game_resumed
signal game_quit

@onready var pause_container: Control = $PauseContainer
@onready var background_opacity: ColorRect = $BackgroundOpacity
@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var lives_label: Label = %LivesLabel


func _init() -> void:
	GameState.points_changed.connect(_on_points_changed)
	GameState.time_changed.connect(_on_time_changed)


func _ready() -> void:
	score_label.text = Util.get_points_text(GameState.points)
	time_label.text = Util.get_time_text(GameState.time_left)
	lives_label.text = "x %s" % str(GameState.lives)


func pause() -> void:
	_set_pause(true)


func unpause() -> void:
	_set_pause(false)


func _set_pause(enabled: bool) -> void:
	background_opacity.visible = enabled
	pause_container.visible = enabled


func _on_resume_button_pressed() -> void:
	_set_pause(false)
	game_resumed.emit()


func _on_quit_button_pressed() -> void:
	game_quit.emit()


func _on_points_changed(points: int) -> void:
	score_label.text = Util.get_points_text(points)


func _on_time_changed(seconds: int) -> void:
	time_label.text = Util.get_time_text(seconds)
