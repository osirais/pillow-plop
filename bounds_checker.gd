extends Node3D
class_name BoundsChecker

@export var bounds_min: Vector3 = Vector3(-100, -100, -100)
@export var bounds_max: Vector3 = Vector3(100, 100, 100)

func _ready():
	
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(_check_bounds)
	timer.autostart = true
	add_child(timer)

func _check_bounds():
	var beds = get_tree().get_nodes_in_group("beds")
	for bed in beds:
		if bed is BaseBed:
			var pos = bed.global_transform.origin
			if pos.x < bounds_min.x or pos.x > bounds_max.x or \
			   pos.y < bounds_min.y or pos.y > bounds_max.y or \
			   pos.z < bounds_min.z or pos.z > bounds_max.z:
				bed.queue_free()

func is_within_bounds(position: Vector3) -> bool:
	return position.x >= bounds_min.x and position.x <= bounds_max.x and \
		   position.y >= bounds_min.y and position.y <= bounds_max.y and \
		   position.z >= bounds_min.z and position.z <= bounds_max.z
