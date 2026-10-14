@tool
class_name TerrainPass
extends GenerationPass

@export var strategy: TerrainStrategy
@export var material: StandardMaterial3D
@export var generate_collision: bool = true

func _generate_data(context: WorldGenContext) -> void:
	if strategy == null:
		push_warning("%s: no TerrainStrategy assigned" % name)
		return
	var heightmap := strategy.generate_data(context, context.get_rng(name))
	if heightmap != null:
		context.set_data(&"heightmap", heightmap)

func _build(context: WorldGenContext) -> void:
	var heightmap: HeightmapData = context.get_data(&"heightmap")
	if heightmap == null:
		return

	var mesh_instance := _build_mesh(heightmap)
	mesh_instance.add_to_group(NAVMESH_SOURCE_GROUP)

	if generate_collision:
		mesh_instance.add_child(_build_collision(heightmap))

	add_generated_child(mesh_instance)

func _build_mesh(heightmap: HeightmapData) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in heightmap.depth:
		for x in heightmap.width:
			var u := float(x) / float(max(heightmap.width - 1, 1))
			var v := float(z) / float(max(heightmap.depth - 1, 1))
			st.set_uv(Vector2(u, v))
			st.add_vertex(Vector3(x * heightmap.cell_size, heightmap.get_height(x, z), z * heightmap.cell_size))

	for z in heightmap.depth - 1:
		for x in heightmap.width - 1:
			var i0 := z * heightmap.width + x
			var i1 := i0 + 1
			var i2 := i0 + heightmap.width
			var i3 := i2 + 1
			st.add_index(i0)
			st.add_index(i1)
			st.add_index(i2)
			st.add_index(i1)
			st.add_index(i3)
			st.add_index(i2)

	st.generate_normals()
	st.generate_tangents()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = st.commit()
	if material:
		mesh_instance.set_surface_override_material(0, material)
	return mesh_instance

func _build_collision(heightmap: HeightmapData) -> StaticBody3D:
	# HeightMapShape3D always spaces samples 1 unit apart, and CollisionShape3D
	# warns on non-uniform scale, so instead of scaling X/Z only, heights are
	# pre-divided by cell_size and a single uniform scale restores both.
	var scaled_heights := PackedFloat32Array()
	scaled_heights.resize(heightmap.heights.size())
	for i in heightmap.heights.size():
		scaled_heights[i] = heightmap.heights[i] / heightmap.cell_size

	var shape := HeightMapShape3D.new()
	shape.map_width = heightmap.width
	shape.map_depth = heightmap.depth
	shape.map_data = scaled_heights

	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(heightmap.world_size().x * 0.5, 0.0, heightmap.world_size().y * 0.5)
	collision.scale = Vector3(heightmap.cell_size, heightmap.cell_size, heightmap.cell_size)

	var body := StaticBody3D.new()
	body.add_child(collision)
	return body
