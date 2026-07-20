class_name Pickuppable
extends Area2D

signal picked_up(type: String)

const COIN = "Coin"
const HAMMER = "Hammer"


func _pick_up() -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	pass
