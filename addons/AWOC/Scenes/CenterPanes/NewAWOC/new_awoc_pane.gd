@tool
extends AWOCCenterPaneBase

@export var awoc_name_line_edit: LineEdit
@export var asset_path_line_edit: LineEdit
@export var create_awoc_button: Button
@export var asset_creation_file_dialog: FileDialog

func init_pane(editor: AWOCEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
	asset_creation_file_dialog.visible = false
	asset_creation_file_dialog.current_dir = "/"
	
"""func _on_new_awoc_dialog_file_selected(path):
	awoc_res = AWOCRes.new(AWOCHelper.get_file_name_from_path(path), path)
	awoc_res.awoc_slots_res = AWOCSlotsRes.new()
	awoc_res.awoc_avatar_res = AWOCAvatarRes.new()
	awoc_res.awoc_slots_res.slots = {}
	awoc_res.save_awoc()
	awoc_editor.awoc_res = awoc_res
	awoc_editor.load_pane(awoc_editor.slots_pane)"""


func _on_file_dialog_dir_selected(dir):
	asset_path_line_edit.text = dir
	
func _on_directory_browse_button_pressed():
	asset_creation_file_dialog.visible = true

func _on_create_awoc_button_pressed():
	var awoc_name = awoc_name_line_edit.text
	if awoc_name.length() < 3:
		printerr("Please enter a name longer than 3 characters")
		return
	if !awoc_name.is_valid_filename():
		printerr("Please do not use special characters in your AWOC name")
		return
	var new_awoc_res = AWOCRes.new()
	new_awoc_res.create_awoc(awoc_name, asset_path_line_edit.text)
	awoc_editor.awoc_res = new_awoc_res
	awoc_editor.load_pane(awoc_editor.slots_pane)
