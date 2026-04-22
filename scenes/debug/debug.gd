@tool
extends Control


@export var enable := true

@onready var logs_container: VBoxContainer = %LogsContainer


func _ready() -> void:
	if Engine.is_editor_hint():
		hide()
		return
	
	if OS.is_debug_build() and enable:
		Debug.setup(self)
		show()
		return


func log(text: String) -> void:
	_add_log(text)


func _add_log(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.theme_type_variation = "DebugLabel"
	
	var logs := logs_container.get_child_count()
	
	if logs > 6:
		logs_container.remove_child(logs_container.get_children()[0])
		logs_container.get_children()[0].queue_free()
	
	logs_container.add_child(label)
