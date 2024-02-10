@tool
class_name AWOCAvatarRes extends Resource

@export var skeleton_res_container: AWOCResContainer
@export var mesh_res_container_dict: Dictionary

var avatar: Node3D
var skeleton: Skeleton3D
var mesh_dictionary: Dictionary
	
func rename_mesh(mesh_name: String, new_name: String, override: bool) -> int:
	return AWOCError.SUCCESS
	
func add_mesh_to_skeleton(mesh_to_add: String) -> int:
	if !mesh_res_container_dict.has(mesh_to_add):
		printerr("Mesh ID dictionary does not contain " + mesh_to_add + "\nAWOCAvatarRes add_mesh_to_skeleton")
		return AWOCError.RESOURCE_ID_NOT_FOUND_IN_DICTIONARY
	if skeleton == null:
		printerr("Skeleton has not been instantiated\nAWOCAvatarRes add_mesh_to_skeleton")
		return AWOCError.RESOURCE_NOT_INITILIZED
	var mesh_res: AWOCMeshRes
	if Engine.is_editor_hint():
		mesh_res = load(ResourceUID.get_id_path(mesh_res_container_dict[mesh_to_add].uid))
	else:
		mesh_res = load(mesh_res_container_dict[mesh_to_add].path)
	if mesh_res == null:
		printerr("AWOCMeshRes not loaded.\nAWOCAvatarRes add_mesh_to_skeleton")
		return AWOCError.RESOURCE_NOT_LOADED
	var de_mesh = mesh_res.deserialize_mesh(skeleton)
	if de_mesh != AWOCError.SUCCESS:
		return de_mesh
	mesh_dictionary[mesh_to_add] = mesh_res.mesh
	return AWOCError.SUCCESS
	
func delete_mesh_from_res(mesh_to_delete: String) -> int:
	if !Engine.is_editor_hint():
		printerr("Must be in editor.")
		return AWOCError.MUST_BE_IN_EDITOR
	if mesh_to_delete.length() < 4:
		printerr("Mesh name to delete must be longer than 3 characters.")
		return AWOCError.INVALID_NAME
	if mesh_res_container_dict == null or !mesh_res_container_dict.has(mesh_to_delete):
		printerr("Mesh ID not found in dictionary")
		return AWOCError.RESOURCE_ID_NOT_FOUND_IN_DICTIONARY
	if !ResourceUID.has_id(mesh_res_container_dict[mesh_to_delete].uid):
		printerr("UID not found in ResourceUID")
		return AWOCError.UID_NOT_FOUND
	var mesh_path: String = ResourceUID.get_id_path(mesh_res_container_dict[mesh_to_delete].uid)
	
	if mesh_path == null:
		printerr("No path was returned from mesh UID")
		return AWOCError.PATH_NOT_RETURNED_FROM_UID
	var delete_mesh = DirAccess.remove_absolute(mesh_path)
	if delete_mesh != OK:
		printerr("There was an error deleting the mesh resource file.")
		return AWOCError.RESOURCE_ON_DISK_NOT_DELETED
	if !mesh_res_container_dict.erase(mesh_to_delete):
		printerr("There was an error deleting the mesh from the mesh_res_container_dict.")
		return AWOCError.RESOURCE_ID_NOT_DELETED
	return AWOCError.SUCCESS
	
func delete_mesh_from_skeleton(mesh_to_delete: String) -> int:
	if !mesh_dictionary.has(mesh_to_delete):
		return AWOCError.RESOURCE_NOT_FOUND_IN_DICTIONARY
	mesh_dictionary[mesh_to_delete].queue_free()
	mesh_dictionary.erase(mesh_to_delete)
	return AWOCError.SUCCESS
	
func save_skeleton_res(skeleton_res: AWOCSkeletonRes, skeleton_path: String):
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	var save_skeleton_res: Error = ResourceSaver.save(skeleton_res, skeleton_path)
	if save_skeleton_res != OK:
		printerr("Error saving AWOCSkeletonRes. ResourceSaver.save error:" + str(save_skeleton_res) + "\nAWOCAvatarRes create_skeleton_res")
		return AWOCError.SAVE_RES_FAILED
	
func create_skeleton_res(skeleton_path: String, source_skeleton: Skeleton3D) -> int:
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	if !skeleton_path.is_absolute_path():
		printerr("Invalid save path for AWOCSKeletonRes.\nAWOCAvatarRes create_skeleton_res")
		return AWOCError.INVALID_PATH
	
	var skeleton_res: AWOCSkeletonRes = AWOCSkeletonRes.new()	
	save_skeleton_res(skeleton_res, skeleton_path)
	
	skeleton_res_container = AWOCResContainer.new()	
	skeleton_res_container.uid = ResourceLoader.get_resource_uid(skeleton_path)
	skeleton_res_container.path = skeleton_path
	if skeleton_res_container.uid == -1:
		printerr("Resource UID not found\nAWOCAvatarRes create_skeleton_res")
		return AWOCError.RESOURCE_ID_NOT_FOUND_IN_DICTIONARY
		
	var serialized_skeleton = skeleton_res.serialize_skeleton(source_skeleton)
	if serialized_skeleton != AWOCError.SUCCESS:
		return serialized_skeleton
		
	save_skeleton_res(skeleton_res, skeleton_path)
	return AWOCError.SUCCESS

func create_avatar_directory(path: String, avatar_path) -> int:
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	var dir = DirAccess.open(path)
	if dir == null:
		printerr(path + " could not be opened.\nAWOCAvatarRes create_avatar_directory")
		return AWOCError.PATH_NOT_OPENED
		
	if !dir.dir_exists(avatar_path):
		var make_dir: Error = dir.make_dir("Avatar")
		if make_dir != OK:
			printerr("Error making Avatar directory. DirAccess.make_dir Error:" + str(make_dir) + "\nAWOCAvatarRes create_avatar_directory")
			return AWOCError.DIRECTORY_NOT_CREATED
			
	return AWOCError.SUCCESS
	
func add_mesh_to_res(mesh: Node, asset_path: String, overwrite: bool) -> int:
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	if !mesh is MeshInstance3D:
		printerr("Node must be a MeshInstance3D")
		return AWOCError.INVALID_PATH
	if !overwrite and mesh_res_container_dict.has(mesh.name):
		return AWOCError.ELEMENT_EXISTS
	
	var mesh_res: AWOCMeshRes = AWOCMeshRes.new()
	mesh_res.serialize_mesh(mesh)
	
	var mesh_path = asset_path + "/Avatar/" + mesh.name + ".res"
	if !mesh_path.is_absolute_path():
		printerr("Invalid mesh path\nAWOCAvatarRes serialize_meshes")
		return AWOCError.INVALID_PATH
		
	var save_mesh: Error = ResourceSaver.save(mesh_res, mesh_path)
	if save_mesh != OK:
		printerr("Save mesh failed. ResourceSaver.save Error: " + str(save_mesh) + "\nAWOCAvatarRes serialize_meshes")
		return AWOCError.SAVE_RES_FAILED
		
	var mesh_id: int = ResourceLoader.get_resource_uid(mesh_path)
	if mesh_id == -1:
		printerr("Mesh ID not found.\nAWOCAvatarRes serialize_meshes")
		return AWOCError.UID_NOT_FOUND
		
	mesh_res_container_dict[mesh.name] = AWOCResContainer.new()
	mesh_res_container_dict[mesh.name].uid = mesh_id
	mesh_res_container_dict[mesh.name].path = mesh_path
	return AWOCError.SUCCESS

func serialize_meshes(source_skeleton: Skeleton3D, avatar_path: String) -> int:
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	if source_skeleton.get_child_count() < 1:
		printerr("No mesh children found in source skeleton.\nAWOCAvatarRes serialize_meshes")
		return AWOCError.NO_MESHES_FOUND_IN_SOURCE_SKELETON
		
	var found: bool = false
	for mesh in source_skeleton.get_children():
		if mesh is MeshInstance3D:
			found = true
			
			var mesh_res: AWOCMeshRes = AWOCMeshRes.new()
			mesh_res.serialize_mesh(mesh)
			
			var mesh_path = avatar_path + "/" + mesh.name + ".res"
			if !mesh_path.is_absolute_path():
				printerr("Invalid mesh path\nAWOCAvatarRes serialize_meshes")
				return AWOCError.INVALID_PATH
				
			var save_mesh: Error = ResourceSaver.save(mesh_res, mesh_path)
			if save_mesh != OK:
				printerr("Save mesh failed. ResourceSaver.save Error: " + str(save_mesh) + "\nAWOCAvatarRes serialize_meshes")
				return AWOCError.SAVE_RES_FAILED
				
			var mesh_id: int = ResourceLoader.get_resource_uid(mesh_path)
			if mesh_id == -1:
				printerr("Mesh ID not found.\nAWOCAvatarRes serialize_meshes")
				return AWOCError.UID_NOT_FOUND
				
			mesh_res_container_dict[mesh.name] = AWOCResContainer.new()
			mesh_res_container_dict[mesh.name].uid = mesh_id
			mesh_res_container_dict[mesh.name].path = mesh_path
	if !found:
		printerr("No meshes found in source skeleton.\nAWOCAvatarRes serialize_meshes")
		return AWOCError.NO_MESHES_FOUND_IN_SOURCE_SKELETON
		
	return AWOCError.SUCCESS
	
func init_avatar():
	avatar = Node3D.new()
	avatar.position = Vector3.ZERO
	avatar.rotation = Vector3.ZERO
	avatar.scale = Vector3.ONE
	
func deserialize_skeleton() -> int:
	var skeleton_res: AWOCSkeletonRes
	if Engine.is_editor_hint():
		if skeleton_res_container == null or skeleton_res_container.uid < 1:
			printerr("No id found for AWOCSkeletonRes.\nAWOCAvatarRes deserialize_skeleton")
			return AWOCError.RESOURCE_ID_NOT_FOUND_IN_DICTIONARY
		skeleton_res = load(ResourceUID.get_id_path(skeleton_res_container.uid))
	else:
		print(skeleton_res_container.path)
		if skeleton_res_container == null or skeleton_res_container.path.length() < 3:
			printerr("No path found for AWOCSkeletonRes.\nAWOCAvatarRes deserialize_skeleton")
			return AWOCError.RESOUCE_PATH_NOT_FOUND_IN_DICTIONARY
		skeleton_res = load(skeleton_res_container.path)
		
	if skeleton_res == null:
		printerr("AWOCSkeletonRes could not be loaded.\nAWOCAvatarRes deserialize_skeleton")
		return AWOCError.RESOURCE_NOT_LOADED
	var skeleton_res_error = skeleton_res.deserialize_skeleton()
	if skeleton_res_error != AWOCError.SUCCESS:
		return skeleton_res_error
	skeleton = skeleton_res.skeleton
	return AWOCError.SUCCESS
	
func serialize_avatar(source_obj: Node, path: String) -> int:
	if !Engine.is_editor_hint():
		return AWOCError.MUST_BE_IN_EDITOR
	if path.length() < 4:
		printerr("Please enter a path that is longer than 3 characters.")
		return AWOCError.INVALID_PATH
	var source_skeleton: Skeleton3D = AWOCSkeletonRes.recursive_get_skeleton(source_obj)
	if source_skeleton == null:
		printerr("Skeleton not found in source node.\nAWOCAvatarRes serialize_avatar")
		return AWOCError.SOURCE_SKELETON_NOT_FOUND
		
	var avatar_path: String = path + "/Avatar"
	var skeleton_path: String = avatar_path + "/skeleton.res"
	
	var create_avatar_dir_error: int = create_avatar_directory(path, avatar_path)
	if create_avatar_dir_error != AWOCError.SUCCESS:
		return create_avatar_dir_error
	
	var create_skeleton_error: int = create_skeleton_res(skeleton_path, source_skeleton)
	if create_skeleton_error != AWOCError.SUCCESS:
		return create_skeleton_error
		
	var serialize_meshes_error: int = serialize_meshes(source_skeleton, avatar_path)
	if serialize_meshes_error != AWOCError.SUCCESS:
		return serialize_meshes_error
		
	return AWOCError.SUCCESS
	
func deserialize_avatar(mesh_list: Array):
	init_avatar()
	var de_skele = deserialize_skeleton()
	if de_skele != AWOCError.SUCCESS:
		return de_skele
	avatar.add_child(skeleton)
	for mesh_name in mesh_list:
		var mesh_res: AWOCMeshRes
		if Engine.is_editor_hint():
			mesh_res = load(ResourceUID.get_id_path(mesh_res_container_dict[mesh_name].uid))
		else:
			mesh_res = load(mesh_res_container_dict[mesh_name].path)
		if mesh_res == null:
			printerr("AWOCMeshRes not loaded.\nAWOCAvatarRes deserialize_avatar")
			return AWOCError.RESOURCE_NOT_LOADED
		var de_mesh: int = mesh_res.deserialize_mesh(skeleton)
		if de_mesh != AWOCError.SUCCESS:
			return de_mesh
		mesh_dictionary[mesh_name] = mesh_res.mesh
