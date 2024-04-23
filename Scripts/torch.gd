extends Sprite2D

@export var max_scale : float = 3
@export var min_scale : float = 1

func _ready():
	var particles = get_node("GPUParticles2D2")
	particles.scale_amount_min = min_scale
	particles.scale_amount_max = max_scale
