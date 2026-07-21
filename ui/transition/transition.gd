class_name Transition
extends CanvasLayer

@export_group("Properties")
@export var level_title: String

@onready var title: Label = %Title
@onready var lives: Label = %Lives
@onready var score: Label = %Score


func _ready() -> void:
	title.text = level_title
	lives.text = "x %s" % str(GameState.lives)
	score.text = Util.get_points_text(GameState.points)
