extends Node

@export var spawn_times: Array[float] = [0.0, 0.2, 1.0]

var fruit_scene = preload("res://scenes/fruit.tscn")
var fruits_spawned = 0
var fruits_saved = 0
var fruits_missed = 0
const FRUIT_START = Vector2(242, 273)
@onready var previous_window_mode = DisplayServer.window_get_mode()
@onready var start_timer = get_tree().create_timer(5)


# Called when the node enters the scene tree for the first time.
func _ready():
	restart()

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
		# FIXME move to next scene
		print("WIN!")

func _on_fruit_outside():
	fruits_missed += 1
	if fruits_missed + fruits_saved == fruits_spawned:
		restart()

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
	%StartProgress.value = 100 * (start_timer.wait_time - %Timer.time_left) / %Timer.wait_time
	if %StartProgress.value == 100:
		%StartProgress.visible = false
	else:
		%StartProgress.visible = true

func restart():
	start_timer.start()
	await start_timer.timeout
	fruits_spawned = 0
	fruits_saved = 0
	fruits_missed = 0
	for time in spawn_times:
		await get_tree().create_timer(time).timeout
		spawn_fruit()

