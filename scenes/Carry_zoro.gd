extends Sprite

func _ready():
	self.visible = false
	
	


func _on_Drone1_done():
	self.visible = false


func _on_Drone1_carry3():
	self.visible = true
