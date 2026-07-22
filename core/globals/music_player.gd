extends AudioStreamPlayer

enum Music {
	MAIN_MENU,
	OUTSIDE,
	UNDERGROUND,
}

const DB_ADJUSTMENT := -6

var music_paths := {
	Music.MAIN_MENU: "uid://c0p7px8vbbx52",
	Music.OUTSIDE: "uid://drf7g53crmgmp",
	Music.UNDERGROUND: "uid://cqgpw1ghyrnbp",
}
var _current_music = null


func play_music(music: Music) -> void:
	if _current_music == music:
		return

	_current_music = music
	stream = load(music_paths[music])
	volume_db = DB_ADJUSTMENT
	play()


func stop_music() -> void:
	stop()


func lower_volume(db := DB_ADJUSTMENT) -> void:
	volume_db += db


func restore_volume() -> void:
	volume_db = DB_ADJUSTMENT
