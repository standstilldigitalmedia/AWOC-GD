@tool
class_name AWOCAvatarRes extends Resource

@export var skeleton_id: int
@export var mesh_ids: Dictionary

var avatar: Node3D
var skeleton: Skeleton3D
var mesh_dictionary: Dictionary

const AVATAR_PATH_NOT_OPENED: int = 1
const AVATAR_DIR_NOT_CREATED: int = 1

const INVALID_SKELETON_PATH: int = 1
const SKELETON_RES_SAVE_FAILED: int = 1
const SKELETON_UID_NOT_FOUND: int = 1
const NO_MESH_CHILDREN_FOUND_IN_SOURCE_SKELETON: int = 1
const NO_MESHES_FOUND_IN_SOURCE_SKELETON: int = 1
const SKELETON_ID_NOT_FOUND: int = 1
const SKELETON_RES_NOT_LOADED: int = 1
const SOURCE_SKELETON_NOT_FOUND: int = 1
const NO_BONES_IN_SOURCE_SKELETON: int = 1
const NO_BONES_IN_SKELETON_RESOURCE: int = 1
const SKELETON_NOT_INITILIZED: int = 1

const INVALID_MESH_TO_DELETE: int = 1
const MESH_ID_NOT_FOUND: int = 1
const PATH_NOT_RETURNED_FROM_MESH_UID: int = 1
const MESH_DIR_NOT_OPENED: int = 1
const MESH_RESOUCE_NOT_DELETED: int = 1
const MESH_ID_NOT_DELETED: int = 1
const INVALID_MESH_PATH: int = 1
const SAVE_MESH_RESOURCE_ERROR: int = 1
const MESH_NOT_LOADED: int = 1
const NO_MESH_SURFACE_FOUND: int = 1
const NO_MESH_SURFACE_ARRAY: int = 1
const MESH_NOT_INITILIZED: int = 1
const NO_MESH_RESOURCE_SURFACE_FOUND: int = 1
const MESH_NOT_FOUND_IN_MESH_DICTIONARY: int = 1
const MESH_NOT_FOUND_IN_MESH_IDS_DICTIONARY: int = 1
const MESH_RESOURCE_NOT_LOADED: int = 1

const SUCCESS = 100

func add_mesh_to_res(node: Node, overwrite: bool) -> int:
	return SUCCESS
	
func rename_mesh(mesh_name: String, new_name: String, override: bool) -> int:
	return SUCCESS
	
func add_mesh_to_skeleton(mesh_to_add: String) -> int:
	if !mesh_ids.has(mesh_to_add):
		printerr("Mesh ID dictionary does not contain " + mesh_to_add + "\nAWOCAvatarRes add_mesh_to_skeleton")
		return MESH_NOT_FOUND_IN_MESH_IDS_DICTIONARY
	if skeleton == null:
		printerr("Skeleton has not been instantiated\nAWOCAvatarRes add_mesh_to_skeleton")
		return SKELETON_NOT_INITILIZED
	var mesh_res: AWOCMeshRes = load(ResourceUID.get_id_path(mesh_ids[mesh_to_add]))
	if mesh_res == null:
		printerr("AWOCMeshRes not loaded.\nAWOCAvatarRes add_mesh_to_skeleton")
		return MESH_RESOURCE_NOT_LOADED
	var de_mesh = mesh_res.deserialize_mesh(skeleton)
	if de_mesh != SUCCESS:
		return de_mesh
	mesh_dictionary[mesh_to_add] = mesh_res.mesh
	return SUCCESS
	
func delete_mesh_from_res(mesh_to_delete: String) -> int:
	if mesh_to_delete.length() < 1:
		return INVALID_MESH_TO_DELETE
	if mesh_ids == null or !mesh_ids.has(mesh_to_delete) or !ResourceUID.has_id(mesh_ids[mesh_to_delete]):
		return MESH_ID_NOT_FOUND
	var mesh_path = ResourceUID.get_id_path(mesh_ids[mesh_to_delete])
	if mesh_path == null:
		return PATH_NOT_RETURNED_FROM_MESH_UID
	var dir = DirAccess.open(mesh_path)
	if dir == null:
		return MESH_DIR_NOT_OPENED
	var delete_mesh = dir.remove(mesh_path)
	if delete_mesh != OK:
		return MESH_RESOUCE_NOT_DELETED
	if !mesh_ids.erase(mesh_to_delete):
		return MESH_ID_NOT_DELETED
	return SUCCESS
	
func delete_mesh_from_skeleton(mesh_to_delete: String) -> int:
	if !mesh_dictionary.has(mesh_to_delete):
		return MESH_NOT_FOUND_IN_MESH_DICTIONARY
	mesh_dictionary[mesh_to_delete].queue_free()
	mesh_dictionary.erase(mesh_to_delete)
	return SUCCESS
	
func save_skeleton_res(skeleton_res: AWOCSkeletonRes, skeleton_path: String):
	var save_skeleton_res: Error = ResourceSaver.save(skeleton_res, skeleton_path)
	if save_skeleton_res != OK:
		printerr("Error saving AWOCSkeletonRes. ResourceSaver.save error:" + str(save_skeleton_res) + "\nAWOCAvatarRes create_skeleton_res")
		return SKELETON_RES_SAVE_FAILED
	
func create_skeleton_res(skeleton_path: String, source_skeleton: Skeleton3D) -> int:
	if !skeleton_path.is_absolute_path():
		printerr("Invalid save path for AWOCSKeletonRes.\nAWOCAvatarRes create_skeleton_res")
		return INVALID_SKELETON_PATH
	
	var skeleton_res: AWOCSkeletonRes = AWOCSkeletonRes.new()	
	save_skeleton_res(skeleton_res, skeleton_path)
		
	skeleton_id = ResourceLoader.get_resource_uid(skeleton_path)
	print("skeleton_id = " + str(skeleton_id))
	if skeleton_id == -1:
		printerr("Resource UID not found\nAWOCAvatarRes create_skeleton_res")
		return SKELETON_UID_NOT_FOUND
		
	var serialized_skeleton = skeleton_res.serialize_skeleton(source_skeleton)
	if serialized_skeleton != SUCCESS:
		return serialized_skeleton
		
	save_skeleton_res(skeleton_res, skeleton_path)
	return SUCCESS

func create_avatar_directory(path: String, avatar_path) -> int:
	var dir = DirAccess.open(path)
	if dir == null:
		printerr(path + " could not be opened.\nAWOCAvatarRes create_avatar_directory")
		return AVATAR_PATH_NOT_OPENED
		
	if !dir.dir_exists(avatar_path):
		var make_dir: Error = dir.make_dir("Avatar")
		if make_dir != OK:
			printerr("Error making Avatar directory. DirAccess.make_dir Error:" + str(make_dir) + "\nAWOCAvatarRes create_avatar_directory")
			return AVATAR_DIR_NOT_CREATED
			
	return SUCCESS

func serialize_meshes(source_skeleton: Skeleton3D, avatar_path: String) -> int:
	if source_skeleton.get_child_count() < 1:
		printerr("No mesh children found in source skeleton.\nAWOCAvatarRes serialize_meshes")
		return NO_MESH_CHILDREN_FOUND_IN_SOURCE_SKELETON
		
	var found: bool = false
	for mesh in source_skeleton.get_children():
		if mesh is MeshInstance3D:
			found = true
			
			var mesh_res: AWOCMeshRes = AWOCMeshRes.new()
			mesh_res.serialize_mesh(mesh)
			
			var mesh_path = avatar_path + "/" + mesh.name + ".res"
			if !mesh_path.is_absolute_path():
				printerr("Invalid mesh path\nAWOCAvatarRes serialize_meshes")
				return INVALID_MESH_PATH
				
			var save_mesh: Error = ResourceSaver.save(mesh_res, mesh_path)
			if save_mesh != OK:
				printerr("Save mesh failed. ResourceSaver.save Error: " + str(save_mesh) + "\nAWOCAvatarRes serialize_meshes")
				return SAVE_MESH_RESOURCE_ERROR
				
			var mesh_id: int = ResourceLoader.get_resource_uid(mesh_path)
			if mesh_id == -1:
				printerr("Mesh ID not found.\nAWOCAvatarRes serialize_meshes")
				return MESH_ID_NOT_FOUND
				
			mesh_ids[mesh.name] = mesh_id
	if !found:
		printerr("No meshes found in source skeleton.\nAWOCAvatarRes serialize_meshes")
		return NO_MESHES_FOUND_IN_SOURCE_SKELETON
		
	return SUCCESS
	
func init_avatar():
	avatar = Node3D.new()
	avatar.position = Vector3.ZERO
	avatar.rotation = Vector3.ZERO
	avatar.scale = Vector3.ONE
	
func deserialize_skeleton() -> int:
	if skeleton_id == null or skeleton_id < 1:
		printerr("No id found for AWOCSkeletonRes.\nAWOCAvatarRes deserialize_skeleton")
		return SKELETON_ID_NOT_FOUND
	var skeleton_res: AWOCSkeletonRes = load(ResourceUID.get_id_path(skeleton_id))
	if skeleton_res == null:
		printerr("AWOCSkeletonRes could not be loaded.\nAWOCAvatarRes deserialize_skeleton")
		return SKELETON_RES_NOT_LOADED
	var skeleton_res_error = skeleton_res.deserialize_skeleton()
	if skeleton_res_error != SUCCESS:
		return skeleton_res_error
	skeleton = skeleton_res.skeleton
	return SUCCESS
	
func serialize_avatar(source_obj: Node, path: String) -> int:
	var source_skeleton: Skeleton3D = AWOCSkeletonRes.recursive_get_skeleton(source_obj)
	if source_skeleton == null:
		printerr("Skeleton not found in source node.\nAWOCAvatarRes serialize_avatar")
		return SOURCE_SKELETON_NOT_FOUND
		
	var avatar_path: String = path + "/Avatar"
	var skeleton_path: String = avatar_path + "/skeleton.res"
	
	var create_avatar_dir_error: int = create_avatar_directory(path, avatar_path)
	if create_avatar_dir_error != SUCCESS:
		return create_avatar_dir_error
	
	var create_skeleton_error: int = create_skeleton_res(skeleton_path, source_skeleton)
	if create_skeleton_error != SUCCESS:
		return create_skeleton_error
		
	var serialize_meshes_error: int = serialize_meshes(source_skeleton, avatar_path)
	if serialize_meshes_error != SUCCESS:
		return serialize_meshes_error
		
	return SUCCESS
	
func deserialize_avatar(mesh_list: Array):
	init_avatar()
	var de_skele = deserialize_skeleton()
	if de_skele != SUCCESS:
		return de_skele
	avatar.add_child(skeleton)
	for mesh_name in mesh_list:
		var mesh_res: AWOCMeshRes = load(ResourceUID.get_id_path(mesh_ids[mesh_name]))
		if mesh_res == null:
			printerr("AWOCMeshRes not loaded.\nAWOCAvatarRes deserialize_avatar")
			return MESH_NOT_LOADED
		var de_mesh: int = mesh_res.deserialize_mesh(skeleton)
		if de_mesh != SUCCESS:
			return de_mesh
		mesh_dictionary[mesh_name] = mesh_res.mesh



"""func add_mesh_to_res(source_mesh: MeshInstance3D, override: bool) -> int:
	if skeleton_array == null or skeleton_array.size() < 1:
		return SKELETON_DOES_NOT_EXIST
	if !override and awoc_mesh_res_dictionary.has(source_mesh.name):
		return MESH_EXISTS
	var surface_count: int = source_mesh.mesh.get_surface_count()
	if surface_count < 1:
		return NO_SURFACE_FOUND
	var surface_arrays: Array
	for a in surface_count:
		surface_arrays.append(source_mesh.mesh.surface_get_arrays(a))
	awoc_mesh_res_dictionary[source_mesh.name] = surface_arrays
	return SUCCESS
		
func create_mesh(mesh_name: String) -> int:
	if !awoc_mesh_res_dictionary.has(mesh_name):
		return MESH_DOES_NOT_EXIST
	var new_mesh: ArrayMesh = ArrayMesh.new()
	var surface_count = awoc_mesh_res_dictionary[mesh_name].size()
	if surface_count < 1:
		return NO_SURFACE_FOUND
	for a in surface_count:
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,awoc_mesh_res_dictionary[mesh_name][a])
	var new_mesh_3d: MeshInstance3D = MeshInstance3D.new()
	skeleton.add_child(new_mesh_3d)
	new_mesh_3d.mesh = new_mesh
	new_mesh_3d.skeleton = NodePath("..")
	mesh_dictionary[mesh_name] = new_mesh_3d
	return SUCCESS

func delete_mesh_from_res(mesh_to_delete: String) -> int:
	
	
func delete_mesh_from_skeleton(mesh_to_delete: String) -> int:
	if mesh_to_delete.length() < 1:
		return INVALID_PATH
	if awoc_mesh_res_dictionary == null or !mesh_dictionary.has(mesh_to_delete):
		return MESH_DOES_NOT_EXIST
	mesh_dictionary[mesh_to_delete].queue_free()
	mesh_dictionary.erase(mesh_to_delete)
	return SUCCESS
	
func rename_mesh(mesh_name: String, new_name: String, override: bool) -> int:
	if !awoc_mesh_res_dictionary.has(mesh_name):
		return MESH_DOES_NOT_EXIST
	if !override and awoc_mesh_res_dictionary.has(new_name):
		return MESH_EXISTS
	awoc_mesh_res_dictionary[new_name] = awoc_mesh_res_dictionary[mesh_name]
	awoc_mesh_res_dictionary.erase(mesh_name)
	return SUCCESS

func add_avatar_to_res(path: String) -> int:
	if path.length() < 1:
		return INVALID_PATH
	var avatar_scene: PackedScene = load(path)
	var avatar: Node3D = avatar_scene.instantiate()
	var new_skeleton: Skeleton3D = recursive_get_skeleton(avatar)
	add_skeleton_to_res(new_skeleton)
	for child in new_skeleton.get_children():
		if child is MeshInstance3D:
			add_mesh_to_res(child,true)
	return SUCCESS
	
func create_avatar(mesh_list: Array):
	if skeleton_array == null or skeleton_array.size() < 1:
		return
	if avatar != null:
		avatar.queue_free()
		avatar = null
		skeleton = null
		mesh_dictionary = {}
	create_skeleton()
	if mesh_list.size() > 0:
		for mesh_name in mesh_list:
			create_mesh(mesh_name)
	avatar = Node3D.new()
	avatar.add_child(skeleton)
	
func clear_avatar():
	if skeleton != null:
		for child in skeleton.get_children():
			child.queue_free()
	
func get_avatar():
	return avatar"""
	
"""namespace AWOC
{
	public class SerializedBone
	{
		public Skeleton3D sourceSkeleton;
		public string boneName;
		public Transform3D globalPoseOverride;
		public int boneParent;
		public Vector3 bonePosition;
		public Vector3 boneScale;
		public Quaternion boneRotation;
		public Transform3D boneRest;

		public SerializedBone(Skeleton3D sourceSkeleton, int index)
		{
			this.sourceSkeleton = sourceSkeleton;
			boneName = sourceSkeleton.GetBoneName(index);
			globalPoseOverride = sourceSkeleton.GetBoneGlobalPoseOverride(index);
			boneParent = sourceSkeleton.GetBoneParent(index);
			bonePosition = sourceSkeleton.GetBonePosePosition(index);
			boneScale = sourceSkeleton.GetBonePoseScale(index);
			boneRotation = sourceSkeleton.GetBonePoseRotation(index);
			boneRest = sourceSkeleton.GetBoneRest(index);
		}
	}

	[Tool]
	public partial class AvatarRes : Resource
	{
		[Export] string avatarName;
		[Export] PackedScene sourceAvatarRes;
		Skeleton3D sourceSkeleton;
		Skeleton3D destSkeleton;
		public Dictionary<string, MeshInstance3D> sourceMeshList;

		public AvatarRes()
		{
			avatarName = "empty";
		}

		public AvatarRes(string avatarName, PackedScene sourceAvatar)
		{
			this.avatarName = avatarName;
			sourceAvatarRes = sourceAvatar;
			InitAvatar();
		}

		Skeleton3D RecursiveGetSkeleton(Node soureceObj)
		{
			if(soureceObj.IsClass("Skeleton3D"))
				return (Skeleton3D)soureceObj;

			foreach(Node child in soureceObj.GetChildren())
			{
				Skeleton3D skele = RecursiveGetSkeleton(child);
				if(skele != null)
					return skele;
			}
			return null;
		}

		SerializedBone[] SerializeSkeleton(Skeleton3D source_skeleton)
		{
			int boneCount = source_skeleton.GetBoneCount();
			SerializedBone[] destSkeleton = new SerializedBone[boneCount];
			for(int a = 0; a < boneCount; a++)
			{
				SerializedBone newBone = new SerializedBone(source_skeleton, a);
				destSkeleton[a] = newBone;
			}
			return destSkeleton;
		}

		Skeleton3D DeserializeSkeleton(SerializedBone[] serializedSkeleton)
		{
			int boneCount = serializedSkeleton.Length;
			Skeleton3D destSkeleton = new Skeleton3D();
			for(int a = 0; a < boneCount; a++)
			{
				destSkeleton.AddBone(serializedSkeleton[a].boneName);
				destSkeleton.SetBoneGlobalPoseOverride(a,serializedSkeleton[a].globalPoseOverride,1);
				destSkeleton.SetBoneParent(a, serializedSkeleton[a].boneParent);
				destSkeleton.SetBonePosePosition(a, serializedSkeleton[a].bonePosition);
				destSkeleton.SetBonePoseScale(a, serializedSkeleton[a].boneScale);
				destSkeleton.SetBonePoseRotation(a, serializedSkeleton[a].boneRotation);
				destSkeleton.SetBoneRest(a, serializedSkeleton[a].boneRest);
			}
			return destSkeleton;
		}

		Godot.Collections.Array[] SerializeMesh(MeshInstance3D mesh)
		{
			int surfaceCount = mesh.Mesh.GetSurfaceCount();
			Godot.Collections.Array[] newMeshArray = new Godot.Collections.Array[surfaceCount];
			for(int a = 0; a < surfaceCount; a++)
			{
				newMeshArray[a] = mesh.Mesh.SurfaceGetArrays(a);
			}
			return newMeshArray;
		}

		MeshInstance3D DeserializeMeshList(List<Godot.Collections.Array[]> meshList, Skeleton3D skeleton)
		{
			ArrayMesh newMesh = new ArrayMesh();
			foreach(Godot.Collections.Array[] mesh in meshList)
			{
				foreach(Godot.Collections.Array surface in mesh)
				{
					newMesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, surface);
				}
			}
			MeshInstance3D newMesh3d = new MeshInstance3D();
			skeleton.AddChild(newMesh3d);
			newMesh3d.Mesh = newMesh;
			newMesh3d.Skeleton = new NodePath("..");
			return newMesh3d;
		}

		public void InitAvatar()
		{
			if(sourceSkeleton != null)
			{
				sourceSkeleton.QueueFree();
				sourceSkeleton = null;
			}
				
			sourceMeshList = new Dictionary<string, MeshInstance3D>();
			Node3D sourceAvatar = sourceAvatarRes.Instantiate<Node3D>();
			sourceSkeleton = RecursiveGetSkeleton(sourceAvatar);
			foreach(var child in sourceSkeleton.GetChildren())
			{
				if(child is MeshInstance3D)
				{
					sourceMeshList.Add(child.Name, (MeshInstance3D)child);
				}
			}
		}

		public Node3D CreateAWOCAvatar(string[] meshList)
		{
			Node3D baseAWOC = new Node3D();
			Node3D armature = new Node3D();
			Skeleton3D destSkeleton = DeserializeSkeleton(SerializeSkeleton(sourceSkeleton));

			List<Godot.Collections.Array[]> sourceMeshes = new List<Godot.Collections.Array[]>();
			for(int a = 0; a < meshList.Length; a++)
			{
				sourceMeshes.Add(SerializeMesh(sourceMeshList[meshList[a]]));
			}
			DeserializeMeshList(sourceMeshes, destSkeleton);
			armature.AddChild(destSkeleton);
			baseAWOC.AddChild(armature);
			return baseAWOC;
		}

		public override bool Equals(Object obj)
		{			
			if(GetHashCode() == obj.GetHashCode())
				return true;
			return false;
		}

		public override int GetHashCode()
		{
			string replaced = string.Empty;
			string stringToHash = avatarName;
			if(sourceMeshList != null)
			{
				Dictionary<string,MeshInstance3D>.KeyCollection keys = sourceMeshList.Keys;
				foreach(string key in keys)
					stringToHash += key;
			}
			stringToHash += "AvatarRes";
			string stringToHashUpper = stringToHash.ToUpper();
			foreach (char c in stringToHashUpper)
			{
				if (char.IsDigit(c))
					replaced += c;
				else if (char.IsLetter(c))  
				{
					int asc = (int)c - (int)'A' + 1;
					replaced += asc;
				}
			} 
			
			if(int.TryParse(replaced, out int j))
				return j;
			else
			{
				GD.Print("TryParse failed in AWOCAvatarRes.GetHashCode()");
				return 1;
			}	
		}
	}
}
		/*
	if source_skeleton != null:
		source_skeleton.queue_free()
	if source_avatar != null:
		source_avatar.queue_free()
	if source_avatar_file != null:
		var source_avatar = source_avatar_file.instantiate()
		source_skeleton = recursive_get_skeleton(source_avatar)
		source_mesh_list = {}
		for source_mesh in source_skeleton.get_children():
			if source_mesh.is_class("MeshInstance3D"):
				source_mesh_list[source_mesh.name] = source_mesh
	
	/*if mesh.is_class("MeshInstance3D"):
		var mesh_array: Array = []
		var surface_count = 
		if surface_count < 1:
			print(mesh.name + " has no surface count")
		for surface in surface_count:
			mesh_array.append(mesh.mesh.surface_get_arrays(surface))
		return mesh_array
	return null

		/*
	
func deserialize_mesh_list(meshes: Array, skeleton: Skeleton3D):
	var new_mesh: ArrayMesh = ArrayMesh.new()
	for mesh in meshes:
		for surface in mesh:
			new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface)
	var new_mesh_3d: MeshInstance3D = MeshInstance3D.new()
	skeleton.add_child.call_deferred(new_mesh_3d)
	new_mesh_3d.mesh = new_mesh
	new_mesh_3d.set_skeleton_path("..")
	return new_mesh_3d
	
func deserialize_mesh(mesh_array: Array, skeleton: Skeleton3D):
	var new_mesh_3d: MeshInstance3D = MeshInstance3D.new()
	skeleton.add_child.call_deferred(new_mesh_3d)
	var new_mesh: ArrayMesh = ArrayMesh.new()
	for array in mesh_array:
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,array)
	new_mesh_3d.mesh = new_mesh
	new_mesh_3d.set_skeleton_path("..")
	#new_mesh_3d.skeleton = skeleton
	return new_mesh_3d
	

	
func init_source_avatar(path: String):
	source_avatar_file = load(path)
	load_source_avatar()
	
*/"""
