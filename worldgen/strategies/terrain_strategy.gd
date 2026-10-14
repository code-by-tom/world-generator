@tool
class_name TerrainStrategy
extends GenerationStrategy

func generate_data(_context: WorldGenContext, _rng: RandomNumberGenerator) -> HeightmapData:
	push_error("%s: generate_data() not implemented" % get_class())
	return null
