extends Camera2D

func _ready():
	enabled = false

func transition(player1, player2, time):
	var cam1 = player1.get_node("Camera2D")
	var cam2 = player2.get_node("Camera2D")
	zoom = cam1.zoom
	limit_left = cam1.limit_left
	limit_right = cam1.limit_right
	limit_top = cam1.limit_top
	limit_bottom = cam1.limit_bottom
	offset = player1.position
	player1.split = true
	player2.split = true
	
	var end_pos = player2.position
	var end_zoom = cam2.zoom
	
	cam1.enabled = false
	cam2.enabled = false
	enabled = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "offset", end_pos, time)
	tween.tween_property(self, "zoom", end_zoom, time)
	
	await get_tree().create_timer(time).timeout
	limit_left = cam2.limit_left
	limit_right = cam2.limit_right
	limit_top = cam2.limit_top
	limit_bottom = cam2.limit_bottom
	cam2.enabled = true
	enabled = false
	
	player2.split = false
