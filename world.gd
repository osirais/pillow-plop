extends Node3D

@onready var object_to_spawn = preload("res://Cube.tscn")
@onready var camera = $Camera3D

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_direction = camera.project_ray_normal(mouse_pos)
		var ray_length = 1000.0

		var ray_params = PhysicsRayQueryParameters3D.new()
		ray_params.from = ray_origin
		ray_params.to = ray_origin + ray_direction * ray_length

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(ray_params)

		var position = result.get("position", ray_params.to)
		var instance = object_to_spawn.instantiate()
		instance.position = position
		add_child(instance)
