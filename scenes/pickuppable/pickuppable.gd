class_name Pickuppable
extends Area2D


const COIN = "Coin"

signal picked_up(type: String)


func _pick_up() -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	pass
