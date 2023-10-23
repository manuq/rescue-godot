extends RigidBody2D

signal floor
signal bounce
signal goal_reached(position)
signal portal_entered
signal out_of_bounds

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var goal_group = get_tree().get_nodes_in_group("goal")
@onready var level_bounds_group = get_tree().get_nodes_in_group("level_bounds")
@onready var bounce_high_group = get_tree().get_nodes_in_group("bounce_high")
@onready var bounce_low_group = get_tree().get_nodes_in_group("bounce_low")

var next_position = null
var next_rotation = null
var next_reset = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# add_constant_central_force(Vector2(40, 0))
	apply_impulse(Vector2(200, -200))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):
	if next_position != null:
		state.transform = Transform2D(rotation, next_position)
		state.linear_velocity = Vector2(cos(next_rotation), sin(next_rotation)) * state.linear_velocity.length()
		next_position = null
		next_rotation = null
	elif next_reset:
		visible = false
		state.transform = Transform2D(0, Vector2())
		state.linear_velocity = Vector2()

func on_free_timeout():
	queue_free()

func on_body_entered(body):
	if body in goal_group:
		goal_reached.emit(get_global_transform_with_canvas().origin)
		$FreeTimer.start()
		next_reset = true
		return
	if body in bounce_high_group:
		apply_impulse(Vector2(50, -250))
		bounce.emit()
	elif body in bounce_low_group:
		apply_impulse(Vector2(100, 0))
		floor.emit()


func _on_hitbox_entered(area):
	if area is PortalIn:
		next_position = area.portal_out.position
		next_rotation = area.portal_out.rotation
		portal_entered.emit()


func _on_hitbox_exited(area):
	if not visible:
		return
	if area in level_bounds_group:
		out_of_bounds.emit()
		queue_free()
