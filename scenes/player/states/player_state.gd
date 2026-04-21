class_name PlayerState
extends State


const IDLE = "Idle"
const AIR = "Air"
const WALK = "Walk"
const RUN = "Run"


var player: Player


func _ready() -> void:
	assert(owner is Player, "Player state must be used with a player.")
	await owner.ready
	player = owner
