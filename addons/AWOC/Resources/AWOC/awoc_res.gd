@tool
class_name AwocRes extends Resource

@export var awoc_name: String
@export var awoc_path: String
@export var awoc_slots_res: AwocSlotsRes 
@export var awoc_avatar_res: AwocAvatarRes
#@export var AvatarRes awocAvatarRes;
#@export var MaterialsRes awocMaterialRes;

func _init(a_name: String = "", a_path: String = ""):
	awoc_name = a_name
	awoc_path = a_path
	
func save_awoc():
	ResourceSaver.save(self, awoc_path)
