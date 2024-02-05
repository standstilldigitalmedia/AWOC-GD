@tool
class_name AWOCResContainer extends Resource

@export var uid: int
@export var path: String

func update_path():
	if Engine.is_editor_hint():
		path = ResourceUID.get_id_path(uid)
	else:
		printerr("Path can only be updated in the editor.")
