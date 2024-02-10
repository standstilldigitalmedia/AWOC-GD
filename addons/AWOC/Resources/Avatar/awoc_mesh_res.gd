@tool
class_name AWOCMeshRes extends Resource

@export var surface_array: Array
var mesh: MeshInstance3D

func serialize_mesh(source_mesh: MeshInstance3D)-> int:
	var surface_count: int = source_mesh.mesh.get_surface_count()
	if surface_count < 1:
		printerr("No surfaces found in mesh " + source_mesh.name + "\nAWOCMeshRes serialize_mesh")
		return AWOCError.NO_MESH_SURFACE_FOUND
	surface_array = []
	for a in surface_count:
		var surface_arrays_get: Array = source_mesh.mesh.surface_get_arrays(a)
		if surface_arrays_get == null or surface_arrays_get.size() < 1:
			printerr("surface_get_arrays returned null.\nAWOCMeshRes serialize_mesh")
			return AWOCError.NO_MESH_SURFACE_ARRAY
		surface_array.append(surface_arrays_get)
	return AWOCError.SUCCESS
		
func deserialize_mesh(skeleton: Skeleton3D) -> int:
	if surface_array == null or surface_array.size() < 1:
		printerr("The mesh resource you are trying to use has not been initilized with mesh data.\nAWOCMeshRes deserialize_mesh")
		return AWOCError.RESOURCE_NOT_INITILIZED
	var new_mesh: ArrayMesh = ArrayMesh.new()
	var surface_count = surface_array.size()
	if surface_count < 1:
		printerr("No surfaces found\nAWOCMeshRes deserialize_mesh")
		return AWOCError.NO_MESH_RESOURCE_SURFACE_FOUND
	for a in surface_count:
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface_array[a])
	mesh = MeshInstance3D.new()
	skeleton.add_child(mesh)
	mesh.skeleton = NodePath("..")
	mesh.mesh = new_mesh
	return AWOCError.SUCCESS
