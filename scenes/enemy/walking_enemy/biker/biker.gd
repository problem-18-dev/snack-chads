extends WalkingEnemy


const DISMOUNTED_BIKE = preload("uid://qqnq6ua6bjfp")


func hurt() -> void:
	_spawn_unmounted_bike()
	super()


func _spawn_unmounted_bike() -> void:
	var bike: WalkingEnemy = DISMOUNTED_BIKE.instantiate()
	bike.setup(global_position)
	get_parent().add_child(bike)
