extends Node


var _debug_node: Node


func setup(node: Node) -> void:
	_debug_node = node


func log(text: String) -> void:
	if not OS.is_debug_build():
		return
	
	_debug_node.log(text)
