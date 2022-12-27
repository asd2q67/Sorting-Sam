extends Label

var value
var str_value = []

func _process(delta):
	self.text = str(value)
	


func _on_Drone1_plan_signal(plan):
	value = plan
