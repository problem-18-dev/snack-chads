class_name HUD
extends CanvasLayer

signal game_resumed
signal game_quit

@onready var pause_container: Control = $PauseContainer
@onready var background_opacity: ColorRect = $BackgroundOpacity


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
