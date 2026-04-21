class_name PseudoRandom extends RefCounted

var last_idx:int = -1
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _init():
	rng.randomize()

func randint(count:int) -> int:
	if count <= 1:
		last_idx = 0
		return 0
	
	var index = rng.randi() % count
	
	if index == last_idx:
		var offset = rng.randi_range(1, count - 1)
		index = (index + offset) % count
	
	last_idx = index
	
	return index

func array_pick_random(array:Array) -> Variant:
	if array.is_empty():
		return null
	return array[randint(array.size())]
