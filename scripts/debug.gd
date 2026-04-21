extends Node


var debug_node: Node


func setup(node: Node) -> void:
	debug_node = node


func log(text: String) -> void:
	debug_node.log(text)
