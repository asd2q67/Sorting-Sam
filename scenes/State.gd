extends Node

class_name States

var pos
var is_carrying
var need_charge
var table_state_empty
var action

func _init(init_pos,init_is_carrying,init_need_charge,init_table_state_empty,init_action):
	pos = init_pos
	is_carrying = init_is_carrying
	need_charge = init_need_charge
	table_state_empty = init_table_state_empty
	action = init_action
	
func _to_string():
	return "[pos:" + pos + ", is_carrying: " + str(is_carrying) + " need_charge: " + str(need_charge) + ", table_state_empty" + str(table_state_empty) + ", action:" + action + "]"

