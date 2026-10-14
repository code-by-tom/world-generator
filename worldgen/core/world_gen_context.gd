@tool
class_name WorldGenContext
extends Resource

## Shared blackboard passed through every pass of a single regenerate() run.
## Passes read/write `data` by StringName key instead of calling each other
## directly, so terrain, structures, and future pass types stay decoupled.

var world_seed: int = 0
var bounds: AABB = AABB(Vector3(-64, -16, -64), Vector3(128, 32, 128))
var data: Dictionary = {}

## Deterministic, per-pass RNG stream. Keying by `stream_key` (pass name)
## instead of tree order means reordering passes in the scene doesn't
## perturb other passes' random sequences.
func get_rng(stream_key: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d::%s" % [world_seed, stream_key])
	return rng

func set_data(key: StringName, value: Variant) -> void:
	data[key] = value

func get_data(key: StringName, default: Variant = null) -> Variant:
	return data.get(key, default)

func has_data(key: StringName) -> bool:
	return data.has(key)
