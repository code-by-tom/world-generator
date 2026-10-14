@tool
class_name StructurePass
extends GenerationPass

@export var strategy: StructureStrategy
@export var flatten_terrain: bool = true
@export var flatten_border: float = 3.0
@export var floor_material: StandardMaterial3D

var _layout: StructureLayoutData

func _generate_data(context: WorldGenContext) -> void:
	if strategy == null:
		push_warning("%s: no StructureStrategy assigned" % name)
		return

	_layout = strategy.generate_data(context, context.get_rng(name))
	if _layout == null:
		return

	context.set_data(StringName("structure_layout:%s" % name), _layout)

	if flatten_terrain and context.has_data(&"heightmap"):
		var heightmap: HeightmapData = context.get_data(&"heightmap")
		for room in _layout.rooms:
			var world_rect := Rect2(room.position + Vector2(position.x, position.z), room.size)
			heightmap.flatten_region(world_rect, position.y, flatten_border)

func _build(_context: WorldGenContext) -> void:
	if _layout == null:
		return
	for room in _layout.rooms:
		add_generated_child(_build_floor(room, _layout.wall_thickness))
	for corridor in _layout.corridors:
		add_generated_child(_build_floor(corridor, _layout.wall_thickness))

func _build_floor(rect: Rect2, thickness: float) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = Vector3(rect.size.x, thickness, rect.size.y)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "StructureFloor"
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(rect.position.x + rect.size.x * 0.5, -thickness * 0.5, rect.position.y + rect.size.y * 0.5)
	mesh_instance.add_to_group(NAVMESH_SOURCE_GROUP)
	if floor_material:
		mesh_instance.set_surface_override_material(0, floor_material)

	var shape := BoxShape3D.new()
	shape.size = box.size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	var body := StaticBody3D.new()
	body.add_child(collision)
	mesh_instance.add_child(body)

	return mesh_instance
