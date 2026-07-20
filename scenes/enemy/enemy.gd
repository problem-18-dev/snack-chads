class_name Enemy
extends CharacterBody2D

@export_group("Debug")
@export var debug_enabled := false

@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D


func pause() -> void:
	pass


func resume() -> void:
	pass
