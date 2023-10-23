extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	play_random($PortalEnteredSounds)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_random(node):
	var a = randi()%node.get_child_count()
	node.get_child(a).play()
	

func on_floor():
	play_random($FloorSounds)

func on_bounce():
	play_random($BounceSounds)

func on_goal_reached(position):
	play_random($GoalReachedSounds)


func _on_portal_entered():
	play_random($PortalEnteredSounds)
