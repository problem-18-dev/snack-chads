extends StaticBody2D

@export var speed := 1.5

@onready var danger_area: Area2D = $DangerArea
@onready var fire_pivot: Node2D = $DangerArea/FirePivot


func _physics_process(delta: float) -> void:
	danger_area.rotation += speed * delta
	for fire in fire_pivot.get_children():
		fire.rotation += speed * delta


func _on_danger_area_body_entered(body: Player) -> void:
	body.take_damage()
