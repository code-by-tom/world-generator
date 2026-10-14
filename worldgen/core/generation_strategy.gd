@tool
class_name GenerationStrategy
extends Resource

## Base type for all swappable generation algorithms (noise terrain, BSP
## structures, future strategies). A strategy only computes data - it never
## touches the scene tree - which is what makes it drag-and-drop swappable
## on a GenerationPass without the pass or pipeline changing.
func generate_data(_context: WorldGenContext, _rng: RandomNumberGenerator) -> Resource:
	push_error("%s: generate_data() not implemented" % get_class())
	return null
