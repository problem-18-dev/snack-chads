extends AudioStreamPlayer

enum Music {
	MAIN_MENU,
	OUTSIDE,
	UNDERGROUND,
}

var music_paths := {
	Music.MAIN_MENU: "uid://c0p7px8vbbx52",
	Music.OUTSIDE: "uid://drf7g53crmgmp",
	Music.UNDERGROUND: "uid://cqgpw1ghyrnbp",
}


func play_music(music: Music) -> void:
	stream = load(music_paths[music])
	volume_db = -2
	play()


func stop_music() -> void:
	stop()


func pause_music() -> void:
	stream_paused = true


func unpause_music() -> void:
	stream_paused = false
