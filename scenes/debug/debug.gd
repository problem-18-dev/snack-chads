extends Control


@onready var logs_container: VBoxContainer = %LogsContainer


func _ready() -> void:
	Debug.setup(self)


func log(text: String) -> void:
	_add_log(text)


func _add_log(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = "DebugLabel"
	
	var logs := logs_container.get_child_count()
	
	if logs > 6:
		logs_container.remove_child(logs_container.get_children()[0])
		logs_container.get_children()[0].queue_free()
	
	logs_container.add_child(label)
