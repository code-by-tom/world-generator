@tool
class_name WorldGenerator3D
extends Node3D

## Orchestrator. Drop this into a scene, add GenerationPass children
## (TerrainPass, StructurePass, NavMeshBakePass, ...) in the order they
## should run, and press Regenerate. Passes are discovered as direct
## children so reordering them in the Scene dock reorders the pipeline.

@export var world_seed: int = 0
@export var world_bounds: AABB = AABB(Vector3(-64, -16, -64), Vector3(128, 32, 128))
@export var auto_regenerate_on_ready: bool = false

@export_tool_button("Regenerate")
var regenerate_button: Callable = regenerate

func _ready() -> void:
	if not Engine.is_editor_hint() and auto_regenerate_on_ready:
		regenerate()

func regenerate() -> void:
	var context := WorldGenContext.new()
	context.world_seed = world_seed
	context.bounds = world_bounds

	var passes := _get_generation_passes()
	for p in passes:
		p.run_data_phase(context)
	for p in passes:
		p.run_build_phase(context)

func _get_generation_passes() -> Array[GenerationPass]:
	var result: Array[GenerationPass] = []
	for child in get_children():
		if child is GenerationPass:
			result.append(child)
	return result
