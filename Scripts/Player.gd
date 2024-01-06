extends CharacterBody2D
@onready var player_scene = load("res://Scenes/Character + Items/player.tscn")
@onready var my_type = "player"

@export var init_speed : int = 90
@export var init_jump : int = 360
@export var init_gravity : int = 16.2

@onready var speed = init_speed * scale.x / 1.8
@onready var jump = init_jump * scale.x / 1.8
@onready var gravity = init_gravity * scale.x / 1.8

@onready var camera_transition = $"../../Camera Transition"

@onready var anim_tree = get_node("AnimationTree")

var darkness : float = 70

@onready var bodies_in_connect_area = []

var in_use = true
signal transition_signal

var right
var run
var idle
var jumping
var split
var connecting

var available_splits

func _ready():
	if not Global.active_player:
		Global.active_player = self
		available_splits = 0
	Global.global_player_activaion.connect(global_activation)
	connect("transition_signal", camera_transition.transition, 3)

var floor
var direction
func _physics_process(delta):
	if not in_use:
		velocity.x = 0
		direction = 0
		get_node("Camera2D").enabled = false
	else:
		floor = is_on_floor()
		direction = Input.get_axis("Left", "Right")
		
		if Input.is_action_just_pressed("Use"):
			slime_split()
		elif Input.is_action_just_pressed("Conect"):
			slime_connect()
		
		if not split:
			move()
		else:
			direction = 0
			velocity.x = 0
			
	if not split:
		update_animations()
	
	gravity_process()
	move_and_slide()

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

func slime_split():
	if not (floor and velocity.x == 0 and not split and not connecting and available_splits > 0):
		return
	
	available_splits -= 1
		
	split = true
	anim_tree["parameters/conditions/split"] = split
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
	get_parent().add_child(new_player)
	
	transition_signal.emit(self, Global.active_player, 0.3)
	
	seceond_body.queue_free()
	self.queue_free()
	
	await get_tree().create_timer(0.3).timeout
	connecting = false
	
	
	


func connect_area_entered(body):
	if body == self:
		return
	if body.scale == self.scale:
		if body.my_type == "player":
			bodies_in_connect_area.append(body)
		elif body.my_type == "blob":
			await floor and velocity.x == 0 and not split and not connecting
			
			
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

	if body.my_type == "flag":
		if snappedf(body.scale[0], 0.1) == Global.max_size[Global.levels.find(get_tree())]:
			if Global.levels.find(get_tree()) + 1 <= Global.levels.size():
				var next_level = Global.levels[Global.levels.find(get_tree()) + 1]
