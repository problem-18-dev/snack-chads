extends CharacterBody2D


enum Direction { Left, Right }

const DIRECTIONS: Dictionary[Direction, int] = {
	Direction.Left: -1,
	Direction.Right: 1,
}

@export_group("Movement")
@export var speed := 20.0
@export_group("Debug")
@export var debug_enabled := false

var _direction := DIRECTIONS[Direction.Left]


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_process_movement()
	var has_collided := move_and_slide()
	_handle_collision(has_collided)


func hurt() -> void:
	if debug_enabled:
		Debug.log("Enemy hurt!")
	
	queue_free()


func _apply_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta


func _process_movement() -> void:
	velocity.x = _direction * speed


func _handle_collision(has_collided: bool) -> void:
	if has_collided:
		var collisions := get_slide_collision_count()
		
		for i in collisions:
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()
			
			if collider == null:
				return
			
			var normal := collision.get_normal()
			if normal.is_equal_approx(Vector2.LEFT):
				_direction = DIRECTIONS[Direction.Left]
			elif normal.is_equal_approx(Vector2.RIGHT):
				_direction = DIRECTIONS[Direction.Right]
