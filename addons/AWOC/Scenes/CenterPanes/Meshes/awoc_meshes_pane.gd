@tool
extends AWOCCenterPaneBase

@export var single_mesh_line_edit: LineEdit
@export var add_single_mesh_button: Button

@export var mesh_file_line_edit: LineEdit
@export var mesh_file_browse_button: Button
@export var add_mesh_file_button: Button

@export var mesh_list_container: VBoxContainer
@export var mesh_container_scene: PackedScene

@export var load_mesh_dialog: FileDialog

@export var mesh_preview_scene: PackedScene
@export var main_container: HBoxContainer

var mesh_preview: AWOCMeshPreview

func populate_mesh_list_container():
	for child in mesh_list_container.get_children():
		child.queue_free()
	#awoc_res.avatar_res.clear_avatar()
	if awoc_res == null or awoc_res.avatar_res == null or awoc_res.avatar_res.skeleton_res_container == null:
		return
	for mesh_name in awoc_res.avatar_res.mesh_res_container_dict:
		var mesh_container = mesh_container_scene.instantiate()
		mesh_container.set_mesh_name(mesh_name)
		mesh_container.awoc_res = awoc_res
		mesh_list_container.add_child(mesh_container)
		
func get_name_from_path(path: String) -> String:
	var split_string = path.split("/")
	return split_string[split_string.size() -1]

func _on_add_single_mesh_button_pressed():
	var path: String = single_mesh_line_edit.text
	if path.length() < 1:
		printerr("Must enter a valid path.")
		return
	var mesh_node: Node = get_node(path)
	
	awoc_res.avatar_res.add_mesh_to_res(mesh_node, awoc_res.asset_creation_path, true)
	awoc_res.save_awoc()
	populate_mesh_list_container()
	single_mesh_line_edit.text = ""

func _on_mesh_file_browse_button_pressed():
	load_mesh_dialog.clear_filters()
	load_mesh_dialog.add_filter("*.glb", "GL Transmission Format Binary file")
	load_mesh_dialog.current_dir = "/"
	load_mesh_dialog.visible = true
	
func create_avatar():
	if awoc_res.avatar_res.skeleton_res_container != null and awoc_res.avatar_res.skeleton_res_container.uid > 0:
		awoc_res.avatar_res.avatar = null
		awoc_res.avatar_res.deserialize_avatar([])
		awoc_res.avatar_res.avatar.position = Vector3.ZERO
		awoc_res.avatar_res.avatar.rotation = Vector3.ZERO
		awoc_res.avatar_res.avatar.scale = Vector3.ONE
		mesh_preview.subject.add_child(awoc_res.avatar_res.avatar)
	
func _on_add_mesh_file_button_pressed():
	var avatar_file = load(mesh_file_line_edit.text)
	var avatar_obj: Node3D = avatar_file.instantiate()
	awoc_res.avatar_res.serialize_avatar(avatar_obj,awoc_res.asset_creation_path)
	awoc_res.save_awoc()
	mesh_file_line_edit.text = ""
	create_avatar()
	populate_mesh_list_container()
	
func _on_load_mesh_dialog_file_selected(path):
	mesh_file_line_edit.text = path
	
func init_pane(editor: AWOCEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
	mesh_preview = mesh_preview_scene.instantiate()
	main_container.add_child(mesh_preview)
	for child in mesh_preview.subject.get_children():
		child.queue_free()
	create_avatar()
	populate_mesh_list_container()
