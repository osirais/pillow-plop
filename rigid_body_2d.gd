extends RigidBody2D

func _ready():
	gravity_scale = 1

	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8)
	])
	poly.color = Color(1, 0, 0)
	add_child(poly)
