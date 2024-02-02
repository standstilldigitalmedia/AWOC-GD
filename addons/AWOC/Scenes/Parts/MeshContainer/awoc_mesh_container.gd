@tool
class_name AwocMeshContainer extends AwocCenterPaneBase

signal show_mesh(m_name: String, show: bool)

@export var mesh_name_line_edit: LineEdit
@export var show_button: Button
@export var hide_button: Button
@export var delete_mesh_confirmation_dialog: ConfirmationDialog
@export var overwrite_mesh_confirmation_dialog: ConfirmationDialog
@export var rename_confirmation_dialog: ConfirmationDialog
var mesh_name: String

func set_mesh_name(m_name: String):
	mesh_name = m_name
	mesh_name_line_edit.text = m_name
	
func _on_save_button_pressed():
	rename_confirmation_dialog.title = "Rename " + mesh_name + "?"
	rename_confirmation_dialog.dialog_text = "Are you sure you wish to rename " + mesh_name + " to " + mesh_name_line_edit.text + "? This can not be undone."
	rename_confirmation_dialog.visible = true
		
func _on_rename_confirmation_dialog_confirmed():
	var saved: int = awoc_res.awoc_avatar_res.rename_mesh(mesh_name, mesh_name_line_edit.text, false)
	if saved == AwocAvatarRes.MESH_DOES_NOT_EXIST:
		printerr("Mesh " + mesh_name + " does not exist")
	if saved == AwocAvatarRes.MESH_EXISTS:
		overwrite_mesh_confirmation_dialog.title = "Overwrite " + mesh_name + "?"
		overwrite_mesh_confirmation_dialog.dialog_text = "Do you wish to overwrite the existing slot named " + mesh_name_line_edit.text + "?" 
		overwrite_mesh_confirmation_dialog.visible = true
		return
	awoc_res.save_awoc()
	queue_free()

func _on_overwrite_mesh_confirmation_dialog_confirmed():
	var saved: int = awoc_res.awoc_avatar_res.rename_mesh(mesh_name, mesh_name_line_edit.text, true)
	if saved == AwocAvatarRes.MESH_DOES_NOT_EXIST:
		printerr("Mesh " + mesh_name + " does not exist")
	awoc_res.save_awoc()
	queue_free()
		
func _on_delete_mesh_confirmation_dialog_confirmed():
	awoc_res.awoc_avatar_res.delete_mesh_from_res(mesh_name)
	awoc_res.awoc_avatar_res.delete_mesh_from_skeleton(mesh_name)
	awoc_res.save_awoc()
	queue_free()
	
func _on_delete_button_pressed():
	delete_mesh_confirmation_dialog.title = "Delete " + mesh_name + "?"
	delete_mesh_confirmation_dialog.dialog_text = "Are you sure you wish to delete " + mesh_name + "? This can not be undone."
	delete_mesh_confirmation_dialog.visible = true

func _on_show_button_pressed():
	awoc_res.awoc_avatar_res.create_mesh(mesh_name)
	show_button.visible = false
	hide_button.visible = true

func _on_hide_button_pressed():
	awoc_res.awoc_avatar_res.delete_mesh_from_skeleton(mesh_name)
	show_button.visible = true
	hide_button.visible = false
	

"""namespace AWOC
{
	[Tool]
	public partial class MeshContainer : HBoxContainer
	{
		[Signal] public delegate void ShowMeshEventHandler(string meshName, bool show);
		[Export] Label meshLabel;
		[Export] Button showButton;
		[Export] Button hideButton;
		string meshName;

		public void SetMeshName(string meshName)
		{
			this.meshName = meshName;
			meshLabel.Text = meshName;
		}

		void _on_show_button_pressed()
		{
			hideButton.Visible = true;
			showButton.Visible = false;
			EmitSignal(SignalName.ShowMesh,meshName,true);
		}

		void _on_hide_button_pressed()
		{
			hideButton.Visible = false;
			showButton.Visible = true;
			EmitSignal(SignalName.ShowMesh,meshName,false);
		}
	}
}"""












