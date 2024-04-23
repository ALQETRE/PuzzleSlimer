extends AnimatedSprite2D

var splits
var fake = false

@onready var button = get_parent().get_node("Button")
@onready var rect = get_parent().get_node("ColorRect")

func _ready():
	if not get_parent().visible:
		fake = true
		
	rect.visible = true
	button.modulate = Color(1, 1, 1, 0)
	rect.modulate = Color(1, 1, 1, 1)
	
	await get_tree().create_timer(0.2).timeout
	var tween = create_tween()
	tween.tween_property(rect, "modulate", Color(1, 1, 1, 0), 0.4)
	await get_tree().create_timer(0.4).timeout
	
	button.visible = true
	await get_tree().create_timer(0.2).timeout
	rect.visible = false
	
	tween = create_tween()
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.3)
	await  get_tree().create_timer(0.3).timeout
	button.disabled = false

func _process(delta):
	if Global.active_player:
		splits = Global.active_player.available_splits
		if splits <= 5:
			frame = splits
		else:
			frame = 5
	if Global.level_end and not fake:
		Global.level_end = false
		fade()

func fade():
	rect.visible = true
	var tween = create_tween()
	tween.tween_property(rect, "modulate", Color(1, 1, 1, 1), 0.4)
	await get_tree().create_timer(0.4).timeout

func reset_button():
	fade()
	await get_tree().create_timer(0.4).timeout
	get_tree().reload_current_scene()
