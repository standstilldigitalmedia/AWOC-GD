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
	"""if !Engine.is_editor_hint():
		printerr("Resource files can only be edited in the editor.\nAWOCRes create_awoc")
		return AWOCError.MUST_BE_IN_EDITOR"""
	awoc_resource_container = AWOCResContainer.new()
	awoc_name = a_name
	asset_creation_path = a_path
	awoc_resource_container.path = asset_creation_path + "/" + awoc_name + ".res"
	slots_res = AWOCSlotsRes.new()
	avatar_res = AWOCAvatarRes.new()
	ResourceSaver.save(self, awoc_resource_container.path)
	#awoc_resource_container.uid = ResourceLoader.get_resource_uid(awoc_resource_container.path)
	save_awoc()
