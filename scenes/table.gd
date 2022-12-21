extends Node2D

var cargo1 = load("res://scenes/spawn_luffy.tscn")
var cargo2 = load("res://scenes/spawn_zoro.tscn")
var cargo3 = load("res://scenes/spawn_nami.tscn")
var cargo_list = []
signal chose(type,weight)
signal table_empty(is_empty)

var _is_table_empty

func _process(delta):
	_is_table_empty = cargo_list.empty()
	emit_signal("table_empty",_is_table_empty)
	if(cargo_list.size() <= 0):
		_on_refill_pressed()

func _on_refill_pressed():
	var cargos = [cargo1,cargo2,cargo3]
	
	for i in rand_range(1,4):
		var kinds = (cargos[randi() % 3])
		var cargo = kinds.instance()
		
		cargo.position.x = rand_range(768+32,896-32)
		cargo.position.y = rand_range(64+32,256-32)

		add_child(cargo) 
		cargo_list.push_back(cargo)
	print(cargo_list)	

func _on_delete_one_pressed():
	
	var a = cargo_list.size()
	if a>0:
		cargo_list[a-1].queue_free()
		cargo_list.pop_back()


func _on_Drone1_selecting():
	var a = cargo_list.size()
	if a>0:
		emit_signal("chose",cargo_list[a-1].type,cargo_list[a-1].weight)	
		print(cargo_list[a-1].type,' - ',cargo_list[a-1].weight)
		cargo_list[a-1].queue_free()
		cargo_list.pop_back()
	


func _on_Drone1_fill():
	_on_refill_pressed()
