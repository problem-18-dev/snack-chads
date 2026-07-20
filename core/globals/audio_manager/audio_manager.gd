extends Node

enum Sfx {
	BIKE_PUSH,
	BLOCK_BREAK,
	BLOCK_BUMP,
	COIN,
	FIREBALL,
	JUMP,
	PIPE,
	STOMP,
	GAME_OVER,
	LEVEL_CLEAR,
	CONSUME,
	PLAYER_HURT,
	PING,
}

var sfx_paths := {
	Sfx.BIKE_PUSH: "uid://c38j8hnc7gopw",
	Sfx.BLOCK_BREAK: "uid://m77w348b5e4d",
	Sfx.BLOCK_BUMP: "uid://c85jmux878gnt",
	Sfx.COIN: "uid://d1vxas5q4u6dl",
	Sfx.FIREBALL: "uid://no33xc223o4v",
	Sfx.JUMP: "uid://d0rvd7swam7wr",
	Sfx.PIPE: "uid://ctn1y3f3kqgvc",
	Sfx.STOMP: "uid://dbeuhy37fiq78",
	Sfx.GAME_OVER: "uid://c6esxmr3yuago",
	Sfx.LEVEL_CLEAR: "uid://by1uybv0oanki",
	Sfx.CONSUME: "uid://d8muhrqdwn6x",
	Sfx.PLAYER_HURT: "uid://5604oesivdw5",
	Sfx.PING: "uid://b7q2ii3tfcx5",
}


func play_sfx(sfx_name: Sfx) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = load(sfx_paths[sfx_name])
	player.pitch_scale = randf_range(0.9, 1.1)
	player.finished.connect(_on_player_finished.bind(player))
	add_child.call_deferred(player)
	player.play.call_deferred()


func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.queue_free()
