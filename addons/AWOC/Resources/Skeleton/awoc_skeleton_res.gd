@tool
class_name AwocSkeletonRes extends Resource

@export var bones: Array

static func recursive_get_skeleton(sourceObj: Node) -> Skeleton3D:
	if sourceObj is Skeleton3D:
		return sourceObj
	for child: Node in sourceObj.get_children():
		var skele: Skeleton3D = recursive_get_skeleton(child)
		if skele != null:
			return skele
	return null

func _init(source_skeleton: Skeleton3D):
	var bone_count = source_skeleton.get_bone_count()
	bones = []
	for a in bone_count:
		var bone_res: AwocBoneRes = AwocBoneRes.new(source_skeleton, a)
		bone_res.serializeBone(source_skeleton, a)
		bones.append(bone_res)
	
func deserialize_skeleton() -> Skeleton3D:
	var bone_count: int = bones.size()
	var dest_skeleton: Skeleton3D = Skeleton3D.new()
	for a in bone_count:
		dest_skeleton.add_bone(bones[a].bone_name)	
		dest_skeleton.set_bone_global_pose_override(a, bones[a].global_pose_override,1)
		dest_skeleton.set_bone_parent(a, bones[a].bone_parent)
		dest_skeleton.set_bone_pose_position(a, bones[a].bone_position)
		dest_skeleton.set_bone_pose_scale(a, bones[a].bone_scale)
		dest_skeleton.set_bone_pose_rotation(a, bones[a].bone_rotation)
		dest_skeleton.set_bone_rest(a, bones[a].bone_rest)
	return dest_skeleton
