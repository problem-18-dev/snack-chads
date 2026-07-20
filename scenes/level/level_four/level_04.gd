extends Level

@onready var door: StaticBody2D = $Objects/Door
@onready var mom_platform: Node2D = $Objects/MomPlatform


func _on_hammer_picked_up(_type: String) -> void:
	door.queue_free()
	mom_platform.queue_free()
