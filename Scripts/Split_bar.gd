extends AnimatedSprite2D

var splits

func _process(delta):
	splits = Global.active_player.available_splits
	if splits <= 5:
		frame = splits
	else:
		frame = 5
