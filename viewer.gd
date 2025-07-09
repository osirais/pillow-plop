extends Node3D

@export var sensitivity := 0.005
@onready var camera = $Camera3D

var yaw := 0.0
var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))  # prevent flipping

		rotation.y = yaw
		camera.rotation.x = pitch
