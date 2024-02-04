@tool
class_name AWOCSkeletonRes extends Resource

@export var bones: Array
var skeleton: Skeleton3D

static func recursive_get_skeleton(sourceObj: Node) -> Skeleton3D:
	if sourceObj is Skeleton3D:
		return sourceObj
		
	for child: Node in sourceObj.get_children():
		var skele: Skeleton3D = recursive_get_skeleton(child)
		if skele != null:
			return skele
			
	return null

func serialize_skeleton(source_skeleton: Skeleton3D) -> int:
	var bone_count = source_skeleton.get_bone_count()
	if bone_count < 1:
		printerr("Source skeleton does not have any bones\nAWOCSkeletonRes serialize_skeleton")
		return AWOCAvatarRes.NO_BONES_IN_SOURCE_SKELETON
		
	bones = []
	for a in bone_count:
		var bone_res: AWOCBoneRes = AWOCBoneRes.new()
		bone_res.serialize_bone(source_skeleton, a)
		bones.append(bone_res)
		
	return AWOCAvatarRes.SUCCESS
	
func deserialize_skeleton() -> int:
	if bones == null or bones.size() < 1:
		printerr("Skeleton resource does not have any bones\n AWOCSkeletonRes deserialize_skeleton")
		return AWOCAvatarRes.NO_BONES_IN_SKELETON_RESOURCE
		
	var bone_count: int = bones.size()
	skeleton = Skeleton3D.new()
	
	for a in bone_count:
		skeleton.add_bone(bones[a].bone_name)	
		skeleton.set_bone_global_pose_override(a, bones[a].global_pose_override,1)
		skeleton.set_bone_parent(a, bones[a].bone_parent)
		skeleton.set_bone_pose_position(a, bones[a].bone_position)
		skeleton.set_bone_pose_scale(a, bones[a].bone_scale)
		skeleton.set_bone_pose_rotation(a, bones[a].bone_rotation)
		skeleton.set_bone_rest(a, bones[a].bone_rest)
		
	return AWOCAvatarRes.SUCCESS
