extends PlayerState


func _enter(data := {}) -> void:
	if data.has("pipe"):
		var pipe: Pipe = data.pipe
		pipe.take_player()
