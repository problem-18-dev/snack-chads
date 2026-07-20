extends Node2D

const DEFAULT_ELASTIC_SCALE := Vector2(1, 0.8)

@export_group("Properties")
@export var elastic_target: AnimatedSprite2D


func _ready() -> void:
	elastic_target.scale = Vector2.ONE


func use(use_scale := DEFAULT_ELASTIC_SCALE) -> void:
	elastic_target.scale = use_scale
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(elastic_target, "scale", Vector2.ONE, 0.2)
