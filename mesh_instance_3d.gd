extends MeshInstance3D

func _process(delta):
	# Rotate around Y axis by 1 radian per second
	rotation.y += 1.0 * delta
