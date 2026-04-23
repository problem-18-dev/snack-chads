class_name SurpriseBlock
extends Block


const DISABLED_TEXTURE: Texture2D = preload("uid://di1dn68pjqkh1")

var _disabled := false


func hit() -> void:
	if _disabled:
		return
	
	_disabled = true
	
	sprite.texture = DISABLED_TEXTURE
	bump()
