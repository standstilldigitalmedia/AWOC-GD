@tool
class_name AWOCRes extends Resource

@export var awoc_name: String
@export var asset_creation_path: String
@export var awoc_uid: int
@export var slots_res: AWOCSlotsRes 
@export var avatar_res: AWOCAvatarRes
@export var mesh_res_ids_array: Array
#@export var AvatarRes awocAvatarRes;
#@export var MaterialsRes awocMaterialRes;

func save_awoc():
	ResourceSaver.save(self, ResourceUID.get_id_path(awoc_uid))
	
func create_awoc(a_name: String = "", a_path: String = ""):
	awoc_name = a_name
	asset_creation_path = a_path
	var new_awoc_path = asset_creation_path + "/" + awoc_name + ".res"
	slots_res = AWOCSlotsRes.new()
	avatar_res = AWOCAvatarRes.new()
	ResourceSaver.save(self, new_awoc_path)
	awoc_uid = ResourceLoader.get_resource_uid(new_awoc_path)
	save_awoc()
