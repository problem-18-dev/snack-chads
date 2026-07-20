class_name Main
extends Node

enum Scene {
	MAIN_MENU,
	LEVEL_ONE,
	LEVEL_ONE_ROOM_ONE,
	LEVEL_TWO,
	LEVEL_TWO_ROOM_ONE,
	LEVEL_TWO_ROOM_TWO,
	LEVEL_THREE,
	LEVEL_FOUR,
	CREDITS,
	TRANSITION,
}

@export_group("Scenes")
@export var initial_scene := Scene.LEVEL_ONE

var _current_scene: Node
var _scene_paths: Dictionary[Scene, String] = {
	Scene.MAIN_MENU: "uid://b8c6p7bmxprbg",
	Scene.LEVEL_ONE: "uid://dab63ts13sv8m",
	Scene.LEVEL_ONE_ROOM_ONE: "uid://byxhe68v53wwa",
	Scene.LEVEL_TWO: "uid://baeaiso4a67ed",
	Scene.LEVEL_TWO_ROOM_ONE: "uid://biy5osm7f328q",
	Scene.LEVEL_TWO_ROOM_TWO: "uid://cnf5awhp2i2ox",
	Scene.LEVEL_THREE: "uid://bwcvt8pdnord",
	Scene.LEVEL_FOUR: "uid://ndxe33khqqff",
	Scene.CREDITS: "uid://5ukcqx4syxbo",
	Scene.TRANSITION: "uid://b4rgsq0f0o7ti",
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.main = self
	load_scene(initial_scene)


func unload_scene() -> void:
	if not _current_scene:
		return

	call_deferred("remove_child", _current_scene)
	_current_scene.queue_free()
	_current_scene = null


func load_scene(new_scene: Scene) -> void:
	unload_scene()

	var scene := load(_scene_paths[new_scene])
	_current_scene = scene.instantiate()
	add_child(_current_scene)
