class_name StateMachine
extends Node


@export var initial_state: State

@onready var _state := initial_state


func _ready() -> void:
	await owner.ready
	
	for child: State in get_children():
		assert(child is State, "State machine has non-state children.")
		child.finished.connect(transition_to_state)
	
	_state._enter()


func _process(delta: float) -> void:
	_state._update(delta)


func _physics_process(delta: float) -> void:
	_state._physics_update(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	_state._key_input(event)


func transition_to_state(state: String, data := {}) -> void:
	var new_state := get_node(state)
	assert(new_state, "New state is invalid")
	
	_state._exit()
	_state = new_state
	_state._enter(data)
