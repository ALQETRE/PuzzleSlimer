extends Node

signal global_player_activaion

var active_player

var levels : Array = ["res://Scenes/Levels/tutorial_1.tscn", "res://Scenes/Levels/tutorial_2.tscn", "res://Scenes/Levels/tutorial_3.tscn", "res://Scenes/Levels/level_1.tscn", "res://Scenes/Levels/level_2.tscn"]

var levels_name : Array = ["Tutorial1", "Tutorial2", "Tutorial3", "Level1", "Level2"]
var max_size : Array = [1, 1, 2, 3, 3]

var last_tutorial = "Tutorial3"

var level_end = false

const path = "user://game-data.json"

func save(content):
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_var(content)
	file = null

func load_game():
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_var()
	return content

var game_data = {}

var def_data = {
	"tutorial": true,
	"last_level": 0
}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save(game_data)
		get_tree().quit()
	
func _ready():
	save(def_data)
	game_data = load_game()
