extends Node2D

@export var rest_length = 2.0
@export var stiffness = 15.0
@export var damping = 1.0

@onready var ray: RayCast2D = $RayCast2D
@onready var player:= get_parent()
@onready var rope := $Line2D

var launched = false
var target: Vector2

func _process(delta: float) -> void:
	ray.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed('grapple'):
		launch()
	if Input.is_action_just_released("grapple"):
		retract()
		
	if launched:
		handle_grapple(delta)
		
func launch():
	if ray.is_colliding():
		launched = true
		target = ray.get_collision_point()
		rope.show()
		
func retract():
	launched = false
	rope.hide()
	
func handle_grapple(delta):
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	
	var spring_force_magnitude = 0.0
	if displacement > 0:
		spring_force_magnitude = stiffness * displacement
		
	var spring_force = target_dir * spring_force_magnitude
	
	var vel_dot = player.velocity.dot(target_dir)
	var damping_force = -damping * vel_dot * target_dir # This is the damping force
	
	# The total force is the spring force plus the damping force
	var total_force = spring_force + damping_force
		
	player.velocity += total_force * delta
	update_rope()

func update_rope():
	rope.set_point_position(1,to_local(target))
