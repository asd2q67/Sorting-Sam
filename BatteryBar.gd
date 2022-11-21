extends Control

signal low_battery(is_low)


onready var battery_bar = $battery
var is_moving = false
var is_charging = false
var weight = 0
func _ready():
	battery_bar.value = 100
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	if(battery_bar.value <=30):
		emit_signal("low_battery",true)
	if(battery_bar.value == 100):
		emit_signal("low_battery",false)

func _on_battery_changed(battery):
	battery_bar.value = battery
	weight = 0


func _on_Drone1_moving():
	is_moving = true
	is_charging = false
	
	

func _on_world_timer_timeout():
	if(is_moving):
		battery_bar.value -= (1 + weight)
	if is_charging:
		battery_bar.value += 5
	





func _on_Drone1_charging():
	is_charging = true



func _on_Drone1_stoping():
	is_moving = false


func _on_Drone1_weightchange(changed_weight):
	weight = changed_weight


func _on_Drone1_done():
	weight = 0
