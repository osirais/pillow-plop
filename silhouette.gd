extends RigidBody3D

@onready var line_node: Line2D = $"../CanvasLayer/Line2D"
@onready var preview_rect: TextureRect = $"../CanvasLayer2/TextureRect"

@export var mesh_to_track: MeshInstance3D

var viewport: SubViewport
var camera: Camera3D
var viewport_scene_root: Node3D

var sub_mesh: MeshInstance3D
var collision_shape: CollisionShape3D

func _setup_viewport():
	viewport = SubViewport.new()
	viewport.set_size(Vector2i(256, 256))
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	sub_mesh = MeshInstance3D.new()
	sub_mesh.mesh = mesh_to_track.mesh
	sub_mesh.top_level = true;

	add_child(viewport)
	
func _process(delta):
	sub_mesh.rotation = mesh_to_track.global_rotation
	collision_shape.global_rotation = Vector3.ZERO
	
	# Extract silhouette and redraw outline
	var silhouette = await extract_silhouette()
	draw_silhouette(silhouette)
	
	create_extruded_collision_shape(silhouette, 3)

func _ready():
	#gravity_scale = 0
	_setup_viewport()
	_setup_camera()
	
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)

	# Create a root Node3D inside the viewport to contain the mesh and camera
	viewport_scene_root = Node3D.new()
	viewport.add_child(viewport_scene_root)

	viewport_scene_root.add_child(sub_mesh)

	# Add the camera inside this root (camera is already set up)
	viewport_scene_root.add_child(camera)

	# No need to assign camera.world; it inherits from the viewport

	preview_rect.texture = viewport.get_texture()

	await get_tree().process_frame

	var silhouette = await extract_silhouette()
	draw_silhouette(silhouette)



func _setup_camera():
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	
	camera.size = 4
	#camera.near = 0.01
	#camera.far = 100.0

	camera.global_transform = Transform3D(Basis(), Vector3(0, 1, 3))
	camera.look_at(Vector3.ZERO, Vector3.UP)

func extract_silhouette() -> PackedVector2Array:
	await get_tree().process_frame

	var img_tex := viewport.get_texture()
	if img_tex == null:
		push_error("Viewport texture is null!")
		return PackedVector2Array()

	var image : Image = img_tex.get_image()
	image.convert(Image.FORMAT_RGBA8)

	var points := PackedVector2Array()
	var w := image.get_width()
	var h := image.get_height()
	for y in range(h):
		for x in range(w):
			var col : Color = image.get_pixel(x, y)
			if col.a > 0.1:
				points.append(Vector2(x, y))

	return Geometry2D.convex_hull(points)

func draw_silhouette(points: PackedVector2Array):
	if points.is_empty():
		print("No silhouette points found.")
		return

	points.append(points[0])
	line_node.points = points
	
func create_extruded_collision_shape(profile_2d: PackedVector2Array, depth: float):
	var shape = ConvexPolygonShape3D.new()

	var vertices_3d = []
	
	var size = viewport.get_size()
	var half_size = camera.size / 2.2
	var aspect = size.x / size.y
	
	for v in profile_2d:
		var nx = v.x / size.x
		var ny = v.y / size.y
		var x = (nx - 0.5) * 2 * half_size
		var y = (0.5 - ny) * 2 * half_size
		vertices_3d.append(Vector3(x, y, 0))
	
	for v in profile_2d:
		var nx = v.x / size.x
		var ny = v.y / size.y
		var x = (nx - 0.5) * 2 * aspect * half_size
		var y = (0.5 - ny) * 2 * half_size
		vertices_3d.append(Vector3(x, y, depth))
	

	shape.points = vertices_3d
	
	collision_shape.shape = shape
	
