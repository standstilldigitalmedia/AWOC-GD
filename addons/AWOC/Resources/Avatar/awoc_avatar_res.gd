@tool
class_name AwocAvatarRes extends Resource

const MESH_EXISTS = 1
const MESH_DOES_NOT_EXIST = 2
const SKELETON_DOES_NOT_EXIST = 3
const INVALID_PATH = 4
const NO_SURFACE_FOUND = 5
const SUCCESS = 10

@export var skeleton_array: Array
@export var awoc_mesh_res_dictionary: Dictionary
var avatar: Node3D
var skeleton: Skeleton3D
var mesh_dictionary: Dictionary

func recursive_get_skeleton(sourceObj: Node) -> Skeleton3D:
	if sourceObj is Skeleton3D:
		return sourceObj
	for child: Node in sourceObj.get_children():
		var skele: Skeleton3D = recursive_get_skeleton(child)
		if skele != null:
			return skele
	return null

func add_skeleton_to_res(source_skeleton: Skeleton3D) -> int:
	var bone_count = source_skeleton.get_bone_count()
	skeleton_array = []
	for a in bone_count:
		var bone_res: AwocBoneRes = AwocBoneRes.new()
		bone_res.serialize_bone(source_skeleton, a)
		skeleton_array.append(bone_res)
	return SUCCESS
	
func create_skeleton() -> int:
	var bone_count: int = skeleton_array.size()
	skeleton = Skeleton3D.new()
	for a in bone_count:
		skeleton.add_bone(skeleton_array[a].bone_name)	
		skeleton.set_bone_global_pose_override(a, skeleton_array[a].global_pose_override,1)
		skeleton.set_bone_parent(a, skeleton_array[a].bone_parent)
		skeleton.set_bone_pose_position(a, skeleton_array[a].bone_position)
		skeleton.set_bone_pose_scale(a, skeleton_array[a].bone_scale)
		skeleton.set_bone_pose_rotation(a, skeleton_array[a].bone_rotation)
		skeleton.set_bone_rest(a, skeleton_array[a].bone_rest)
	return SUCCESS

func add_mesh_to_res(source_mesh: MeshInstance3D, override: bool) -> int:
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
	if mesh_to_delete.length() < 1:
		return INVALID_PATH
	if awoc_mesh_res_dictionary == null or !awoc_mesh_res_dictionary.has(mesh_to_delete):
		return MESH_DOES_NOT_EXIST
	awoc_mesh_res_dictionary.erase(mesh_to_delete)
	return SUCCESS
	
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
	return avatar
	
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
