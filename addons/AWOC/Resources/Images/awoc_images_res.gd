@tool
class_name AWOCImagesRes extends Resource

@export var images: Dictionary

func add_image(path: String, overwrite: bool) -> int:
	var image_name: String = AWOCHelper.get_file_name_from_path(path)
	if !overwrite and images.has(image_name):
		return AWOCError.ELEMENT_EXISTS
	var res_container: AWOCResContainer = AWOCResContainer.new()
	res_container.path = path
	res_container.uid = ResourceLoader.get_resource_uid(path)
	images[image_name] = res_container
	return AWOCError.SUCCESS
	
func delete_image(image_name: String) -> int:
	if !images.has(image_name):
		return AWOCError.ELEMENT_DOES_NOT_EXIST
	images.erase(image_name)
	return AWOCError.SUCCESS
