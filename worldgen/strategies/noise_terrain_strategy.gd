@tool
class_name NoiseTerrainStrategy
extends TerrainStrategy

@export var resolution: Vector2i = Vector2i(64, 64)
@export var cell_size: float = 4.0
@export var height_scale: float = 24.0
@export var noise_frequency: float = 0.02
@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
@export var fractal_octaves: int = 4
@export var fractal_gain: float = 0.5

func generate_data(_context: WorldGenContext, rng: RandomNumberGenerator) -> HeightmapData:
	var noise := FastNoiseLite.new()
	noise.seed = rng.randi()
	noise.noise_type = noise_type
	noise.frequency = noise_frequency
	noise.fractal_octaves = fractal_octaves
	noise.fractal_gain = fractal_gain

	var heightmap := HeightmapData.new()
	heightmap.width = max(resolution.x, 2)
	heightmap.depth = max(resolution.y, 2)
	heightmap.cell_size = cell_size
	heightmap.heights.resize(heightmap.width * heightmap.depth)

	for z in heightmap.depth:
		for x in heightmap.width:
			heightmap.heights[z * heightmap.width + x] = noise.get_noise_2d(x, z) * height_scale

	return heightmap
