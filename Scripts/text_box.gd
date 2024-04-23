extends Node2D

@export var dialog : Array = [""]

@onready var label = $"Label"
@onready var button = $"Button"

func _ready():
	button.visible = false
	label.text = ""
	
	if Global.game_data["tutorial"]:
		return
		
	await get_tree().create_timer(0.4).timeout
	for text in dialog:
		label.text = ""
		await get_tree().create_timer(0.4).timeout
		for letter in text:
			button.visible = false
			if letter == " ":
				label.text = label.text + letter
				await get_tree().create_timer(0.07).timeout
			elif letter == "\\":
				label.text = label.text + "\n"
				await get_tree().create_timer(0.1).timeout
			else:
				label.text = label.text + letter
				await get_tree().create_timer(0.03).timeout
		
		button.position.y = label.get_rect().end.y-5
		await get_tree().create_timer(0.1).timeout
		button.visible = true
		await button.pressed
		button.visible = false
	label.text = ""
