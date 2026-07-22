extends Control

@onready var high_score: Label = $HighScore


func _ready() -> void:
	MusicPlayer.play_music(MusicPlayer.Music.MAIN_MENU)

	var new_high_score := GameState.save_high_score()

	if new_high_score > 0:
		high_score.text += "\n%s" % Util.get_points_text(new_high_score)
		high_score.show()


func _on_continue_button_pressed() -> void:
	GameState.reset_game_state()
	GameManager.main.load_scene(Main.Scene.MAIN_MENU)
