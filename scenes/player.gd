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
signal fill()
signal state_signal(state)
signal plan_signal(plan)
 
var start_state = States.new("counter",false,false,false,'waiting')

var test_state = States.new("cargo_table",true,true,true,'waiting')

var current_state = States.new("counter",false,false,false,'waiting')

var goal_pickup_cargo = States.new("cargo_table",true,null,null,"pickup")

var goal_sort_luffy = States.new("luffy",false,null,null,'putdown')

var goal_sort_nami = States.new("nami",false,null,null,'putdown')

var goal_sort_zoro = States.new("zoro",false,null,null,'putdown')

var goal_charge_battery = States.new("charge_station",null,false,null,"charge")

var _target
var charge_station = Vector2(64+16,64+16)
var table_location = Vector2(832-64,160)
var luffy_location = Vector2(160,320)
var zoro_location = Vector2(160 + 64* 8 + 32,320)
var nami_location = Vector2(160 + 64*5 ,320)
var type_carried = 0 #1 is luffy - 2 is nami - 3 is zoro
var weight_carried = 0
var table_state_empty
var fCost
	

func _ready():
	_target = self.position
	emit_signal("fill")
	

func _process(delta):
	var plan = a_star(start_state,goal_selector(start_state))
	plan_deployment(plan,delta)
	emit_signal("state_signal",str(current_state))
	emit_signal("plan_signal",plan)
	
	
	
	#	[THIS IS THE GOAL ORIENTED SESSION]
#In goal oriented method we use greedy algorim to select goal depend on drone current state
func goal_selector(state):
	if state.need_charge:
		if charge_consider(_target):
			return goal_charge_battery
	if !state.is_carrying:
		return goal_pickup_cargo
			#1 is luffy - 2 is nami - 3 is zoro
	if state.is_carrying:
		if type_carried == 1:
			return goal_sort_luffy
		if type_carried == 2:
			return goal_sort_nami
		if type_carried == 3:
			return goal_sort_zoro
		
func charge_consider(target):
	var to_target_distant = self.position.distance_to(target)
	var to_target_charge = self.position.distance_to(charge_station)
	var target_to_charge = target.distance_to(charge_station)
	var to_charge_consume_battery = (to_target_charge / 92) * (weight_carried + 1)
	var do_goal_and_charge_consume_battery = (to_target_distant / 92) * (weight_carried + 1) + (target_to_charge / 92) 
	if to_charge_consume_battery <= do_goal_and_charge_consume_battery:
		return true
	return false
#	return weight_carried
	

	#	[THIS IS THE ACTION PLANER SESSION]
#	This bot use A* search algorim to design the action plan
#	A* need a heuristic function and a neighbor function to process

#	first is the heuristic function(caculate the estimate cost of current to goal)
func cmp_state(state_a,state_b):

	
	return (state_a.pos == state_b.pos
	&& ( state_a.is_carrying == state_b.is_carrying || state_a.is_carrying == null || state_b.is_carrying == null)
	&& (state_a.need_charge == state_a.need_charge || state_a.need_charge == null || state_b.need_charge == null)
	&& (state_a.table_state_empty == state_b.table_state_empty || state_a.table_state_empty == null || state_b.table_state_empty == null)
	&& (state_a.action == state_b.action || state_a.action == null || state_b.action == null))

func heuristic(a,b):
	var cost = 0
	if a.is_carrying != null:
		if a.is_carrying != b.is_carrying:
			cost+=1

	if b.need_charge != null:
		if a.need_charge != b.need_charge:
			cost+=1

	if b.table_state_empty != null:
		if a.table_state_empty != b.table_state_empty:
			cost+=1

	if b.pos != null:
		if a.pos != b.pos:
			cost+=1

	return cost

#	second is neighbor function which is to show all posible action 
#	related to current state and it's cost -> defaut = 1

func neighbors(state):
	var pos_list = ['cargo_table', 'luffy', 'nami','zoro','charge_station']
	var states = []
	
#	print(state.pos)
	
	for position in pos_list:
		var t_state = States.new(state.pos,state.is_carrying,state.need_charge,state.table_state_empty,state.action)
		states += [move(t_state,position)]
	for i in range(4):

		if(i==0):
			var t_state = States.new(state.pos,state.is_carrying,state.need_charge,state.table_state_empty,state.action)
			states += [charge(t_state)]
		elif i==1:
			var t_state = States.new(state.pos,state.is_carrying,state.need_charge,state.table_state_empty,state.action)
			states += [putdown(t_state)]	
		elif i==2:
			var t_state = States.new(state.pos,state.is_carrying,state.need_charge,state.table_state_empty,state.action)
			states += [pickup(t_state)]
	var result = []
	for r_state in states:
		if r_state != null:
			result += [r_state]
	
	return result
	
#	this is list of acton and its change to the state

func move(a,to):
	if a.pos == to:
		return null
		
	a.pos = to
	a.action = 'move to ' + to
	
	return a
	
func pickup(state):
	if state.is_carrying:
		return null
	if state.pos != "cargo_table" :
		return null

	state.is_carrying = true
	state.action = 'pickup'

	return state

func putdown(state):
	if !state.is_carrying:
		return null
	if state.pos != "luffy" && state.pos != "zoro" && state.pos != "nami":
		return null

	state.is_carrying = false
	state.action = 'putdown'
	return state
	
func charge(state):
	if (!state.need_charge || state.pos != 'charge_station'):
		return null
	

	state.need_charge = false
	state.action = 'charge'

	return state
	

#Now we move to the main function of Action planning called A* searching algorithm
func a_star(start, goal):
	var open_set = [start]
	var came_from = {}
	
	#G-score is cost of start node to N
	
	var g_score = {}
	g_score[start.action] = 0
	
	# Estimated cost of path from start node through n to goal
	# This is an estimate of the total path cost: f_score = g_score + heuristic
	var f_score = {}
	f_score[start.action] = heuristic(start, goal)
	
	#now is the selecting session
	var count = 0
	while open_set.size() >0:
#		count+=1
#		print(count)
		#first we chose current -> the node with the lowest f_Score
		var current = open_set[0]
		var c = 0
		var index = 0
		
		for i in open_set:
#			print("F-score of: " + i.action + ": " + str(f_score[i.action]))
			if f_score[i.action] <= f_score[current.action]:
				current = i
				index = c
				
			c+=1
		open_set.pop_at(index)

#		print(current)


#		print("current neighbor is: ", neighbors(current) )
#		print("open set is: ",open_set)
#		print("came from is: ", came_from)
#		print("G-score set is: ", g_score)
		if cmp_state(current,goal):
#			print("done")
			return reconstruct_path(came_from,current)
		
		
		
		for neighbor in neighbors(current):
#			print(neighbor.action)
			var temp_g_score = g_score.get(current.action,100000000) + 1
#			print(temp_g_score ," : ", str(g_score.get(neighbor.action,100000000)))
			if temp_g_score < g_score.get(neighbor.action,100000000):
				came_from[neighbor.action] = current
				g_score[neighbor.action] = temp_g_score
				f_score[neighbor.action] = g_score[neighbor.action] + heuristic(neighbor,goal)
				
				if !(neighbor in open_set):
#					print("added: " + neighbor.action )
					open_set.append(neighbor)
#		if count == 3 : return



func reconstruct_path(came_from, current):
	
	var total_path = [current.action]
	while current.action in came_from:
		current = came_from[current.action]
		total_path.insert(0,current.action)
		
	total_path.pop_at(0)
	return total_path
	

# end of action planing

#[THIS IS THE PLAN DEPLOYMENT SESSION]
# after we have the plan we need to convert that plan to real designed action 
func plan_deployment(plan,delta):
	var target_list = {
		'cargo_table' : table_location,
		'luffy' : luffy_location,
		'nami' : nami_location,
		'zoro' : zoro_location,
		'charge_station' : charge_station
	}
	
	for i in plan:
		if 'move to' in i:
			action_to_target(delta,target_list[i.substr(8,i.length()-8)],i.substr(8,i.length()-8))
			
		if 'charge' in i:
			action_charge()
		if 'pickup' in i:
			action_select()
		if 'putdown' in i:
			action_putdown()


# [THIS IS DESIGNED ACTION SESSION]
# below is all the designed action that can work in the program
func action_to_target(delta,target,location):
	_target = target
	if self.position.distance_to(target) > 1 :
		var direction = self.position.direction_to(target)
		move_and_collide(direction * delta * 100)
		emit_signal("moving")
		var act = "move to " + str(location)
		current_state.action = act
#		print(location)
	else:
		
		emit_signal("stoping")
	if self.position.distance_to(target) <= 1 :
		current_state.pos = location
		
		
func action_stop():
	_target = self.position

func action_charge():
	_pick_charger_station()
	if self.position.distance_to(_target) <= 1 :
		emit_signal("stoping")
		emit_signal("charging")
		current_state.action = "charge"
	
func action_select():
	if self.position.distance_to(table_location) <= 1 :
		var count = 0;
	
		if count == 0:	
			emit_signal("selecting")
			count+=1

func action_putdown():
	var table_list = {
		'luffy' : luffy_location,
		'nami' : nami_location,
		'zoro' : zoro_location
	}
	var type_list = ['none','luffy','nami','zoro']
	
	if self.position.distance_to(table_list[type_list[type_carried]]) <= 1 :
		var cmd = "increse_" + type_list[type_carried]
		emit_signal(cmd)
		start_state["is_carrying"] = false
		current_state.is_carrying = false
		emit_signal("done")
		type_carried = 0
		current_state.action = "putdown"

func _pick_cargo_table_position():
	_target = table_location
	
	print("to cargo table")

func _pickup(type,weight):
	if type == 1:

		emit_signal("carry1")
	elif type == 3:

		emit_signal("carry3")
	else:

		emit_signal("carry2")
	emit_signal("weightchange",weight)
	current_state.action = "pick up"
	
#	table._on_delete_one_pressed()
	

	



func _pick_charger_station():
	_target = charge_station
	


# [THIS IS THE RESPONSE SESSION]
# below this comment is all the response funtion we use 
# for responing to to the signal from another script
	


func _on_to_charger_station_pressed():
	_pick_charger_station()


func _on_table_chose(type, weight):
	type_carried = type
	weight_carried = weight
	print(type_carried,type_carried)
	_pickup(type_carried,weight_carried)
	start_state["is_carrying"] = true
	current_state.is_carrying = true


func _on_BatteryBar2_low_battery(is_low):
	start_state["need_charge"] = is_low
	current_state.need_charge = is_low


func _on_table_table_empty(is_empty):
	start_state["table_state_empty"] = is_empty
	current_state.table_state_empty = is_empty
