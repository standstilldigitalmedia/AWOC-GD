@tool
class_name AWOCRes extends Resource

@export var awoc_name: String
@export var asset_creation_path: String
@export var awoc_resource_container: AWOCResContainer
@export var slots_res: AWOCSlotsRes 
@export var avatar_res: AWOCAvatarRes
@export var mesh_res_ids_array: Array
#@export var AvatarRes awocAvatarRes;
#@export var MaterialsRes awocMaterialRes;

func save_awoc():
	"""if !Engine.is_editor_hint():
		printerr("Resource files can only be edited in the editor.\nAWOCRes save_awoc")
		return AWOCError.MUST_BE_IN_EDITOR"""
	ResourceSaver.save(self, awoc_resource_container.path)
	
func create_awoc(a_name: String = "", a_path: String = ""):
	if a_name.length() < 4:
		printerr("Please enter a name that is longer than 3 characters.")
		return AWOCError.INVALID_NAME
	if a_path.length() < 4:
		printerr("Please enter a path that is longer than 3 characters.")
		return AWOCError.INVALID_PATH
		
	"""if !Engine.is_editor_hint():
		printerr("Resource files can only be edited in the editor.\nAWOCRes create_awoc")
		return AWOCError.MUST_BE_IN_EDITOR"""
	awoc_name = a_name
	asset_creation_path = a_path
	var awoc_path: String = asset_creation_path + "/" + awoc_name + ".res"
	awoc_resource_container = AWOCResContainer.new()
	slots_res = AWOCSlotsRes.new()
	avatar_res = AWOCAvatarRes.new()
	ResourceSaver.save(self, awoc_path)
	awoc_resource_container.path = awoc_path
	awoc_resource_container.uid = ResourceLoader.get_resource_uid(awoc_path)
	save_awoc()
