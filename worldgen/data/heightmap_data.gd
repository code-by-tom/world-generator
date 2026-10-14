@tool
class_name HeightmapData
extends Resource

## Grid of Y heights on the XZ plane, local to whatever pass produced it
## (origin at grid cell 0,0). Shared through WorldGenContext under the
## "heightmap" key so any later pass can sample or flatten it.

@export var width: int = 0
@export var depth: int = 0
@export var cell_size: float = 1.0
@export var heights: PackedFloat32Array = PackedFloat32Array()

func get_height(x: int, z: int) -> float:
	x = clampi(x, 0, width - 1)
	z = clampi(z, 0, depth - 1)
	return heights[z * width + x]

func set_height(x: int, z: int, value: float) -> void:
	if x < 0 or x >= width or z < 0 or z >= depth:
		return
	heights[z * width + x] = value

func world_size() -> Vector2:
	return Vector2((width - 1) * cell_size, (depth - 1) * cell_size)

func sample_height(world_x: float, world_z: float) -> float:
	var gx: float = world_x / cell_size
	var gz: float = world_z / cell_size
	var x0 := clampi(int(floor(gx)), 0, width - 1)
	var z0 := clampi(int(floor(gz)), 0, depth - 1)
	var x1 := clampi(x0 + 1, 0, width - 1)
	var z1 := clampi(z0 + 1, 0, depth - 1)
	var tx: float = clampf(gx - x0, 0.0, 1.0)
	var tz: float = clampf(gz - z0, 0.0, 1.0)
	var hx0 := lerpf(get_height(x0, z0), get_height(x1, z0), tx)
	var hx1 := lerpf(get_height(x0, z1), get_height(x1, z1), tx)
	return lerpf(hx0, hx1, tz)

## Flattens heights inside `rect` (world-space XZ) to `flat_height`, with a
## linear falloff ring `border` wide outside it so structures blend in
## instead of leaving a cliff.
func flatten_region(rect: Rect2, flat_height: float, border: float = 2.0) -> void:
	var expanded := rect.grow(max(border, 0.0))
	for z in depth:
		for x in width:
			var point := Vector2(x * cell_size, z * cell_size)
			if not expanded.has_point(point):
				continue
			if rect.has_point(point):
				set_height(x, z, flat_height)
				continue
			var dist := _distance_outside_rect(point, rect)
			var t := clampf(dist / max(border, 0.001), 0.0, 1.0)
			set_height(x, z, lerpf(flat_height, get_height(x, z), t))

func _distance_outside_rect(point: Vector2, rect: Rect2) -> float:
	var dx: float = maxf(rect.position.x - point.x, point.x - rect.end.x)
	var dz: float = maxf(rect.position.y - point.y, point.y - rect.end.y)
	return maxf(dx, dz)
