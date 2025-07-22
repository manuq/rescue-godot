extends Node2D

var fruit_scene = preload("res://scenes/fruit.tscn")
var fruits_spawned = 0
var fruits_saved = 0
var fruits_missed = 0
const FRUIT_START = Vector2(242, 273)
const spawn_times = [0.0, 0.2, 5.0, 5.5]
@onready var previous_window_mode = DisplayServer.window_get_mode()
# @onready var start_timer =


func spawn_fruit():
	var fruit = fruit_scene.instantiate()
	$Fruits.add_child(fruit)
	fruit.position = FRUIT_START
	fruit.goal_reached.connect(_on_fruit_at_goal)
	fruit.out_of_bounds.connect(_on_fruit_outside)
	fruits_spawned += 1

func _on_fruit_at_goal(pos):
	var w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h = ProjectSettings.get_setting("display/window/size/viewport_height")
	var foo = Vector2((pos.x)/w, pos.y/h)
	$GoalEffect/ColorRect.material.set_shader_parameter("center", foo)
	$AnimationPlayer.play("goal-animation")
	fruits_saved += 1
	if fruits_saved == fruits_spawned:
		await get_tree().create_timer(0.8).timeout
		%WinLayer.visible = true

func _on_fruit_outside():
	fruits_missed += 1
	if fruits_missed + fruits_saved == fruits_spawned:
		%StartTimer.start()

func toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		previous_window_mode = DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(previous_window_mode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_timer_timeout():
	fruits_spawned = 0
	fruits_saved = 0
	fruits_missed = 0
	for time in spawn_times:
		await get_tree().create_timer(time).timeout
		spawn_fruit()
