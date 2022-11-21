extends Node

signal battery_changed(battery)

var max_battery = 100
export(int) var battery

func _ready():
	battery = max_battery
	



func _on_rest_timer_timeout():
	battery = battery -1
	emit_signal("battery_changed",battery)
