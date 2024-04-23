extends Area2D

@export var text_frame = 0

func _ready():
	get_node("Sprite2D").frame = text_frame


func _on_body_entered(body):
	get_node("Sprite2D").offset = Vector2(0.5, 0.5)
	get_node("Sprite2D").modulate = Color(0.6, 0.6, 0.6)
	await get_tree().create_timer(0.4).timeout
	get_node("Sprite2D").offset = Vector2(0, 0)
	get_node("Sprite2D").modulate = Color(1, 1, 1)
