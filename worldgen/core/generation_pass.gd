@tool
class_name GenerationPass
extends Node3D

## Base type for every step in the world-gen pipeline (terrain, structures,
## navmesh baking, and whatever gets added later). WorldGenerator3D drives
## all passes through two sweeps in scene-tree order:
##   1. run_data_phase()  on every pass, then
##   2. run_build_phase() on every pass
## so a later pass (e.g. structures) can read/mutate data an earlier pass
## (e.g. terrain) produced before anything builds its final mesh.

const GENERATED_GROUP := &"worldgen_generated"
const NAVMESH_SOURCE_GROUP := &"navmesh_source"

@export var enabled: bool = true

func run_data_phase(context: WorldGenContext) -> void:
	if enabled:
		_generate_data(context)

func run_build_phase(context: WorldGenContext) -> void:
	clear_generated()
	if enabled:
		_build(context)

## Override to compute/mutate shared data. Must not touch the scene tree.
func _generate_data(_context: WorldGenContext) -> void:
	pass

## Override to build nodes (meshes, collision, etc.) from data in context.
func _build(_context: WorldGenContext) -> void:
	pass

func clear_generated() -> void:
	for child in get_children():
		if child.is_in_group(GENERATED_GROUP):
			remove_child(child)
			child.free()

## Adds a generated node, tags it for cleanup on the next regenerate, and
## (in-editor) assigns owner recursively so it's saved with the scene.
func add_generated_child(node: Node) -> void:
	node.add_to_group(GENERATED_GROUP)
	add_child(node)
	if Engine.is_editor_hint():
		var edited_root := get_tree().edited_scene_root
		if edited_root:
			_assign_owner_recursive(node, edited_root)

func _assign_owner_recursive(node: Node, owner_node: Node) -> void:
	node.owner = owner_node
	for child in node.get_children():
		_assign_owner_recursive(child, owner_node)
