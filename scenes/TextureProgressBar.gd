extends TextureProgressBar

@onready var timer = get_parent()

func _process(delta):
	value = 100 * (timer.wait_time - timer.time_left) / timer.wait_time
	if value == 100:
		visible = false
	else:
		visible = true
