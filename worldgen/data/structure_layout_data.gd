@tool
class_name StructureLayoutData
extends Resource

## Output of a StructureStrategy: room/corridor footprints local to the
## StructurePass that produced them (origin at the pass's own position).

@export var rooms: Array[Rect2] = []
@export var corridors: Array[Rect2] = []
@export var wall_thickness: float = 0.3
