extends Label


# Declare member variables here. Examples:
var value 
var done 


# Called when the node enters the scene tree for the first time.
func _ready():
	value = 0
	
func _process(delta):
	self.text = str(value)


func _on_Drone1_increse_luffy():
	if done == 1:
		value +=1


func _on_Drone1_done():
	done += 1


func _on_Drone1_moving():
	done = 1
