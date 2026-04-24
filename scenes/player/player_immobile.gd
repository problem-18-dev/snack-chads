extends PlayerState


func _enter(data := {}) -> void:
	if data.has("interactable"):
		var interactable = data.interactable
		interactable.interact()
