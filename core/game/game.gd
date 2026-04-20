extends Node


@onready var coins: Node2D = $Coins
@onready var debug: Control = $HUD/Debug


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for coin: Pickuppable in coins.get_children():
		coin.picked_up.connect(_on_coin_picked_up)


func _on_coin_picked_up(type: String) -> void:
	debug.log("Picked up a %s!" % type)


func _on_player_died() -> void:
	debug.log("Player died")
