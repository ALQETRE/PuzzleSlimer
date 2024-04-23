extends CharacterBody2D
@onready var player_scene = load("res://Scenes/Character/player.tscn")
@onready var my_type = "player"

@export var init_speed : int = 90
@export var init_jump : int = 360
@export var init_gravity : int = 16

@onready var speed = init_speed * scale.x / 1.8
@onready var jump = init_jump * scale.x / 1.8
@onready var gravity = init_gravity * scale.x / 1.8

@onready var camera_transition = $"../../Camera Transition"
@onready var camera = get_node("Camera2D")
@onready var anim_tree = get_node("AnimationTree")

var darkness : float = 70

@onready var bodies_in_connect_area = []

var in_use = true
signal transition_signal

var right
var run
var idle
var jumping = false
var split
var connecting

var available_splits

@export var camera_active = true

func _ready():
	var tilemap
	if get_tree().current_scene.name == "Menu":
		tilemap = get_parent().get_node("TileMap")
	else:
		tilemap = $"../../TileMap"
		
	var tilemap_rect = tilemap.get_used_rect()
	var tilemap_cell_size = 16
	
	camera.limit_left = tilemap_rect.position.x * tilemap_cell_size
	camera.limit_right = tilemap_rect.end.x * tilemap_cell_size
	camera.limit_top = tilemap_rect.position.y * tilemap_cell_size
	camera.limit_bottom = tilemap_rect.end.y * tilemap_cell_size
	
	if not Global.active_player:
		Global.active_player = self
		available_splits = 0
		split = false
		connecting = false
	Global.global_player_activaion.connect(global_activation)
	if camera_active:
		connect("transition_signal", camera_transition.transition, 3)
	else:
		get_node("Camera2D").enabled = false

var floor = false
var direction
func _physics_process(delta):
	if not in_use:
		velocity.x = 0
		direction = 0
		get_node("Camera2D").enabled = false
	else:
		direction = Input.get_axis("Left", "Right")
		
		if Input.is_action_just_pressed("Use"):
			slime_connect()
		
		if floor:
			velocity.y = 0
			jumping = false
		if not split:
			move()
		else:
			direction = 0
			velocity.x = 0
			
	if not split:
		update_animations()
	
	gravity_process()
	move_and_slide()
	floor = is_on_floor()

func gravity_process():
	if not floor:
		velocity.y += gravity

func move():
	
	if Input.is_action_pressed("Jump") and floor:
		velocity.y = -jump
		jumping = true
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = 0
	
func update_animations():
	if floor and direction:
		run = true
		idle = false
	if  not jumping and not direction:
		run = false
		idle = true
	if direction == 1:
		right = false
	elif direction == -1:
		right = true
	if jumping:
		idle = false
		run = false
	if jumping and (velocity.y > 0):
		jumping = false
		idle = true

	anim_tree["parameters/conditions/idle"] = idle
	anim_tree["parameters/conditions/run"] = run
	
	anim_tree["parameters/conditions/left"] = not right
	anim_tree["parameters/conditions/right"] = right
	
	anim_tree["parameters/conditions/jump"] = jumping

func slime_split(spike):
	if not(not split and not connecting and available_splits > 0):
		return
	velocity.x = 0
	
	anim_tree["parameters/conditions/run"] = false
	anim_tree["parameters/conditions/idle"] = true
	
	available_splits -= 1
		
	split = true
	anim_tree["parameters/conditions/split"] = split
	spike.queue_free()
	await get_tree().create_timer(0.4).timeout
	anim_tree["parameters/conditions/split"] = false
	
	for i in 2:
		var new_player = player_scene.instantiate()
		new_player.position = position + Vector2(7*i*scale.x-4*scale.x, i*1.5)
		new_player.scale = scale / 2
		new_player.get_node("Camera2D").zoom = get_node("Camera2D").zoom*2
		new_player.set_script(load("res://Scripts/Player.gd"))
		new_player.split = true
		new_player.available_splits = available_splits
		if not i == 0:
			new_player.in_use = false
			darken(new_player, true)
		else:
			Global.active_player = new_player
		get_parent().add_child(new_player)
	transition_signal.emit(self, Global.active_player, 0.3)
	await get_tree().create_timer(0.3).timeout
	split = false
	self.queue_free()


func activate():
	Global.global_player_activaion.emit()
	in_use = true
	transition_signal.emit(Global.active_player, self, 0.5)
	Global.active_player = self
	get_node("Button").visible = false
	darken(self, false)
	

func global_activation():
	in_use = false
	get_node("Button").visible = true
	darken(self, true)


func darken(player, darken):
	
	if darken:
		var amount = darkness / 100
		player.modulate = Color(amount, amount, amount)
	else:
		player.modulate = Color(1, 1, 1)
		
func slime_connect():
	if not(floor and velocity.x == 0 and not split and not connecting):
		return
	
	var seceond_body
	if bodies_in_connect_area.size() == 0:
		return
	else:
		seceond_body = bodies_in_connect_area[0]
	
	connecting = true
	available_splits += 1
	
	var new_player = player_scene.instantiate()
	new_player.position = (position + seceond_body.position) / 2
	new_player.scale = scale * 2
	new_player.get_node("Camera2D").zoom = get_node("Camera2D").zoom/2
	new_player.set_script(load("res://Scripts/Player.gd"))
	new_player.available_splits = available_splits
	Global.active_player = new_player
	new_player.connecting = false
	get_parent().add_child(new_player)
	
	transition_signal.emit(self, Global.active_player, 0.3)
	
	seceond_body.queue_free()
	self.queue_free()
	
	await get_tree().create_timer(0.3).timeout

	


func connect_area_entered(body):
	if body == self:
		return
	if body.scale == self.scale:
		if body.my_type == "player":
			bodies_in_connect_area.append(body)
		elif body.my_type == "blob":
			if not(not split and not connecting):
				return
			velocity.x = 0
			
			connecting = true
			available_splits += 1
			
			var new_player = player_scene.instantiate()
			new_player.position = (position + body.position) / 2
			new_player.scale = scale * 2
			new_player.get_node("Camera2D").zoom = get_node("Camera2D").zoom/2
			new_player.set_script(load("res://Scripts/Player.gd"))
			new_player.available_splits = available_splits
			Global.active_player = new_player
			get_parent().add_child(new_player)
			
			transition_signal.emit(self, Global.active_player, 0.3)
			
			body.queue_free()
			self.queue_free()
			
			await get_tree().create_timer(0.3).timeout
			connecting = false
			
	if body.my_type == "spike":
		slime_split(body)
			
	if body.my_type == "flag":
		if self.available_splits == Global.max_size[Global.levels_name.find(get_tree().current_scene.name)]:
			if Global.levels_name.find(get_tree().current_scene.name) + 1 < Global.levels.size():
				var level_name = get_tree().current_scene.name
				var next_level = Global.levels[Global.levels_name.find(get_tree().current_scene.name) + 1]
				if level_name == Global.last_tutorial:
					Global.game_data["tutorial"] = true
				Global.level_end = true
				Global.game_data["last_level"] += 1
				await  get_tree().create_timer(0.5).timeout
				get_tree().change_scene_to_file(next_level)
			else:
				Global.level_end = true
				Global.game_data["last_level"] = 0
				await  get_tree().create_timer(0.5).timeout
				get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func connect_area_exited(body):
	bodies_in_connect_area.erase(body)
