extends Label

onready var state = $Current_stae
var value = "none"

func _process(delta):
	self.text = value

func _on_Drone1_state_signal(state):
	value = state.replace(","," ||")
