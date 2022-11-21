# This NPC does not use GOAP.
# This is just a simple script which chooses
# a random position in the scene to move to.
extends KinematicBody2D


signal moving()
signal stoping()
signal charging()
signal selecting()
signal weightchange(changed_weight)
signal increse_luffy()
signal increse_nami()
signal increse_zoro()
signal carry1()
signal carry2()
signal carry3()
signal done()
 

var current_state = {
	"pos" : "counter",
	"is_carrying" : false,
	"need_charge" : true,
	"table_state_empty" : true,
	"action" : 'wating'
}


var goal_pickup_cargo ={
	"pos" : "cargo_table",
	"is carrying" : true,
	"need_charge" : null,
	"table_state_empty" : null
}

var goal_sort_luffy = {
	"pos" : "luffy",
	"is carrying" : false,
	"need_charge" : null,
	"table_state_empty" : null
}

var goal_sort_nami = {
	"pos" : "nami",
	"is carrying" : false,
	"need_charge" : null,
	"table_state_empty" : null
}

var goal_sort_zoro = {
	"pos" : "zoro",
	"is carrying" : false,
	"need_charge" : null,
	"table_state_empty" : null
}

var goal_charge_battery = {
	"pos" : "charge_station",
	"is carrying" : null,
	"need_charge" : false,
	"table_state_empty" : null
}


var _target
var charge_station = Vector2(64+16,64+16)
var table_location = Vector2(832-64,160)
var luffy_location = Vector2(160,320)
var zoro_location = Vector2(160 + 64* 8 + 32,320)
var nami_location = Vector2(160 + 64*5 ,320)
var type_carried
var weight_carried
var table_state_empty

func _on_to_cargo_table_pressed():
	pass
	

func _ready():
	_target = self.position
	current_state["is_carrying"] = false
	current_state["need_charge"] = false
	current_state["table_state_empty"] = true
	

func _process(delta):
	print(a_star(current_state,goal_sort_luffy))
	#action_to_cargo_table(delta)
	

	#	[THIS IS THE ACTION PLANER SESSION]
#	This bot use A* search algorim to design the action plan
#	A* need a heuristic function and a neighbor function to process

#	first is the heuristic function(caculate the estimate cost of current to goal)
func cmp_dictionary(dic_a,dic_b):
	return dic_a.hash() == dic_b.hash()

func heuristic(a,b):
	var cost = 4
	if a.is_carrying != null:
		if a.is_carrying == b.is_carrying:
			cost-=1
	if a.need_charge != null:
		if a.need_charge == b.need_charge:
			cost-=1
	if a.table_state_empty != null:
		if a.table_state_empty == b.table_state_empty:
			cost-=1
	if a.pos != null:
		if a.pos == b.pos:
			cost-=1
	return cost

#	second is neighbor function which is to show all posible action 
#	related to current state and it's cost -> defaut = 1

func neighbor(state):
	var pos_list = ['cargo_table', 'luffy', 'nami','zoro','charge_station']
	var states = []

	for pos in pos_list:
		var t_state = state.duplicate()
		states += [move(t_state,pos)]
	for i in range(4):
		
		if(i==0):
			var t_state = state.duplicate()
			states += [charge(t_state)]
		elif i==1:
			var t_state = state.duplicate()
			states += [putdown(t_state)]	
		elif i==2:
			var t_state = state.duplicate()
			states += [pickup(t_state)]
	var result = []
	for r_state in states:
		if r_state != null:
			result += [r_state]
	
	return result
	
#	this is list of acton and its change to the state

func move(state,to):
	if state.pos == to:
		return null
		
	state.pos = to
	state.action = 'move to ' + to
	
	return state
	
func pickup(state):
	if state.is_carrying:
		return null

	state.is_carrying = true
	state.action = 'pickup'

	return state

func putdown(state):
	if !state.is_carrying:
		return null

	state.is_carrying = false
	state.action = 'putdown'
	return state
	
func charge(state):
	if !state.need_charge:
		return null
	

	state.need_charge = false
	state.action = 'charge'

	return state
	

#Now we move to the main function of Action planning called A* searching algorithm
func a_star(start, goal):
	var open_set = [start]
	var came_from = []
	
	#G-score is cost of start node to N
	
	var g_score = []
	g_score[start] = 0
	
	# Estimated cost of path from start node through n to goal
	# This is an estimate of the total path cost: f_score = g_score + heuristic
	var f_score = []
	f_score[start.hash] = heuristic(start, goal)
	
	#now is the selecting session
	while open_set.len() >0:
		#first we chose current -> the node with the lowest f_Score
		var current = open_set[0]
		var c = 0
		var index
		for i in open_set:
			if f_score[i] < current:
				current = f_score[i]
				index = c
			c+=1
		open_set.pop(index)
		
		if current.hash() == goal.hash():
			reconstruct_path(came_from,current)
		
		for neighbor in neighbor(current):
			var temp_g_score = g_score.get(current,100000000) + 1
			if temp_g_score < g_score.get(neighbor,100000000):
				came_from[neighbor] = current
				g_score.neighbor = temp_g_score
				f_score.neighbor = g_score[neighbor] + heuristic(neighbor,goal)
			
				if !(neighbor in open_set):
					open_set.append(neighbor)

func reconstruct_path(came_from, current):
	var total_path = [current]
	
	while current in came_from:
		current = came_from[current]
		total_path.insert(0,current)
		
	return total_path




# end of action planing
func action_to_cargo_table(delta):
	_pick_cargo_table_position()
	if self.position.distance_to(_target) > 1 :
		var direction = self.position.direction_to(_target)
		move_and_collide(direction * delta * 100)
		emit_signal("moving")
	else:
		emit_signal("stoping")
		
func action_stop():
	_target = self.position

func action_to_charge_station(delta):
	_pick_charger_station()
	if self.position.distance_to(_target) > 1 :
		var direction = self.position.direction_to(_target)
		move_and_collide(direction * delta * 100)
		emit_signal("moving")
	else:
		emit_signal("stoping")
		emit_signal("charging")
		current_state["need_charge"] = false
	
func action_select_and_move(delta):
	
	if _target == table_location:	
		emit_signal("selecting")
	if self.position.distance_to(_target) > 1 :
		var direction = self.position.direction_to(_target)
		move_and_collide(direction * delta * 100)
		emit_signal("moving")
	else:
		emit_signal("stoping")
		if self.position.distance_to(luffy_location) <= 1:
			emit_signal("increse_luffy")
			current_state["is_carrying"] = false
			emit_signal("done")
				
		if self.position.distance_to(nami_location) <= 1:
			emit_signal("increse_nami")
			current_state["is_carrying"] = false
			emit_signal("done")
				
		if self.position.distance_to(zoro_location) <= 1:
			emit_signal("increse_zoro")
			current_state["is_carrying"] = false
			emit_signal("done")	
			



#	set_process(false)
	# warning-ignore:return_value_discarded


func _pick_cargo_table_position():
	_target = Vector2(832-64,160)
	
	print("to cargo table")

func _pick(type,weight):
	if type == 1:
		_pick_luffy_table()
		emit_signal("carry1")
	elif type == 3:
		_pick_zoro_table()
		emit_signal("carry3")
	else:
		_pick_nami_table()
		emit_signal("carry2")
	emit_signal("weightchange",weight)
	
#	table._on_delete_one_pressed()
	
func _pick_luffy_table():
	_target = Vector2(160,320)
	print("to luffy table")
	
func _pick_nami_table():
	_target = nami_location

func _pick_zoro_table():
	_target = zoro_location
func _pick_charger_station():
	_target = charge_station
	
func pick_up(Luffy_cargo):
	Luffy_cargo._pickup()




func _on_to_luffy_table_pressed():
	_pick_luffy_table()
	


func _on_to_charger_station_pressed():
	_pick_charger_station()


func _on_table_chose(type, weight):
	type_carried = type
	weight_carried = weight
	print(type_carried,type_carried)
	_pick(type_carried,weight_carried)
	current_state["is_carrying"] = true


func _on_BatteryBar2_low_battery(is_low):
	current_state["need_charge"] = is_low


func _on_table_table_empty(is_empty):
	current_state["table_state_empty"] = is_empty
