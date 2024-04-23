extends Node2D

@onready var button = get_node("Button")

func _on_quit_body_entered(body):
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_play_body_entered(body):
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(Global.levels[Global.game_data["last_level"]])


func _reset_game():
	button.disabled = true
	Global.save(Global.def_data)
	Global.game_data = Global.load_game()
	await get_tree().create_timer(0.3).timeout
	button.disabled = false
	get_tree().reload_current_scene()
