@tool
class_name NavMeshBakePass
extends GenerationPass

## Bakes over every mesh tagged NAVMESH_SOURCE_GROUP by earlier passes,
## regardless of where those meshes sit in the tree. Order this pass last
## among a WorldGenerator3D's children so it runs after all other passes'
## build phases have created their geometry.

@export var agent_radius: float = 0.5
@export var agent_height: float = 1.8
@export var agent_max_slope: float = 45.0
@export var cell_size: float = 0.25
@export var cell_height: float = 0.25

func _build(context: WorldGenContext) -> void:
	var nav_mesh := NavigationMesh.new()
	nav_mesh.agent_radius = agent_radius
	nav_mesh.agent_height = agent_height
	nav_mesh.agent_max_slope = agent_max_slope
	nav_mesh.cell_size = cell_size
	nav_mesh.cell_height = cell_height
	nav_mesh.filter_baking_aabb = context.bounds
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_MESH_INSTANCES
	nav_mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	nav_mesh.geometry_source_group_name = NAVMESH_SOURCE_GROUP

	var region := NavigationRegion3D.new()
	region.name = "BakedNavigationRegion"
	region.navigation_mesh = nav_mesh

	add_generated_child(region)
	region.bake_navigation_mesh(false)
