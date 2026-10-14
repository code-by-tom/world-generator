@tool
class_name BSPStructureStrategy
extends StructureStrategy

@export var footprint_size: Vector2 = Vector2(48, 48)
@export var max_depth: int = 4
@export var min_leaf_size: float = 8.0
@export var room_padding: float = 1.0
@export var corridor_width: float = 2.0
@export var wall_thickness: float = 0.3

func generate_data(_context: WorldGenContext, rng: RandomNumberGenerator) -> StructureLayoutData:
	var leaves: Array[Rect2] = []
	_split(Rect2(Vector2.ZERO, footprint_size), max_depth, rng, leaves)

	var layout := StructureLayoutData.new()
	layout.wall_thickness = wall_thickness
	for leaf in leaves:
		var room := leaf.grow(-room_padding)
		if room.size.x > 0.0 and room.size.y > 0.0:
			layout.rooms.append(room)
	layout.corridors = _connect_rooms(leaves)
	return layout

func _split(rect: Rect2, depth: int, rng: RandomNumberGenerator, out_leaves: Array[Rect2]) -> void:
	var can_split_h := rect.size.y > min_leaf_size * 2.0
	var can_split_w := rect.size.x > min_leaf_size * 2.0
	if depth <= 0 or not (can_split_h or can_split_w):
		out_leaves.append(rect)
		return

	var split_horizontal: bool
	if can_split_h and can_split_w:
		split_horizontal = rng.randf() > 0.5
	else:
		split_horizontal = can_split_h

	if split_horizontal:
		var split_at := rng.randf_range(min_leaf_size, rect.size.y - min_leaf_size)
		_split(Rect2(rect.position, Vector2(rect.size.x, split_at)), depth - 1, rng, out_leaves)
		_split(Rect2(rect.position + Vector2(0, split_at), Vector2(rect.size.x, rect.size.y - split_at)), depth - 1, rng, out_leaves)
	else:
		var split_at := rng.randf_range(min_leaf_size, rect.size.x - min_leaf_size)
		_split(Rect2(rect.position, Vector2(split_at, rect.size.y)), depth - 1, rng, out_leaves)
		_split(Rect2(rect.position + Vector2(split_at, 0), Vector2(rect.size.x - split_at, rect.size.y)), depth - 1, rng, out_leaves)

func _connect_rooms(leaves: Array[Rect2]) -> Array[Rect2]:
	var corridors: Array[Rect2] = []
	for i in range(1, leaves.size()):
		var a: Vector2 = leaves[i - 1].position + leaves[i - 1].size * 0.5
		var b: Vector2 = leaves[i].position + leaves[i].size * 0.5
		var half := corridor_width * 0.5
		corridors.append(Rect2(Vector2(min(a.x, b.x), a.y - half), Vector2(abs(b.x - a.x) + corridor_width, corridor_width)))
		corridors.append(Rect2(Vector2(b.x - half, min(a.y, b.y)), Vector2(corridor_width, abs(b.y - a.y) + corridor_width)))
	return corridors
