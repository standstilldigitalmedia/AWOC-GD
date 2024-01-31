@tool
class_name AwocMeshRes extends Resource

@export var surface_arrays: Array

func _init(source_mesh: MeshInstance3D):
	for a in source_mesh.mesh.get_surface_count():
		surface_arrays.append(source_mesh.mesh.surface_get_arrays(a))
		
func deserialize_mesh(skeleton: Skeleton3D) -> MeshInstance3D:
	var new_mesh: ArrayMesh = ArrayMesh.new()
	for a in surface_arrays.size():
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface_arrays)
	var new_mesh_3d: MeshInstance3D = MeshInstance3D.new()
	skeleton.add_child(new_mesh_3d)
	new_mesh_3d.mesh = new_mesh
	new_mesh_3d.skeleton = NodePath("..")
	return new_mesh_3d
