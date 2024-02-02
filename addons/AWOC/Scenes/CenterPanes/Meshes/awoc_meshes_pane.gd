@tool
extends AwocCenterPaneBase

@export var single_mesh_line_edit: LineEdit
@export var add_single_mesh_button: Button

@export var mesh_file_line_edit: LineEdit
@export var mesh_file_browse_button: Button
@export var add_mesh_file_button: Button

@export var mesh_list_container: VBoxContainer
@export var mesh_container_scene: PackedScene

@export var load_mesh_dialog: FileDialog

@export var subject: Node3D

func populate_mesh_list_container():
	for child in mesh_list_container.get_children():
		child.queue_free()
	awoc_res.awoc_avatar_res.clear_avatar()
	if awoc_res == null or awoc_res.awoc_avatar_res == null or awoc_res.awoc_avatar_res.awoc_mesh_res_dictionary == null:
		return
	for mesh_name in awoc_res.awoc_avatar_res.awoc_mesh_res_dictionary:
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
	awoc_res.awoc_avatar_res.add_mesh_to_res(get_node(path),true)
	awoc_res.save_awoc()
	populate_mesh_list_container()
	single_mesh_line_edit.text = ""

func _on_mesh_file_browse_button_pressed():
	load_mesh_dialog.clear_filters()
	load_mesh_dialog.add_filter("*.glb", "GL Transmission Format Binary file")
	load_mesh_dialog.current_dir = "/"
	load_mesh_dialog.visible = true
	
func _on_add_mesh_file_button_pressed():
	awoc_res.awoc_avatar_res.add_avatar_to_res(mesh_file_line_edit.text)
	awoc_res.save_awoc()
	mesh_file_line_edit.text = ""
	populate_mesh_list_container()
	
func _on_load_mesh_dialog_file_selected(path):
	mesh_file_line_edit.text = path
	
func init_panel(editor: AwocEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
	populate_mesh_list_container()
	awoc_res.awoc_avatar_res.create_avatar([])
	for child in subject.get_children():
		child.queue_free()
	if awoc_res.awoc_avatar_res.avatar != null:
		awoc_res.awoc_avatar_res.avatar.position = Vector3.ZERO
		awoc_res.awoc_avatar_res.avatar.rotation = Vector3.ZERO
		awoc_res.awoc_avatar_res.avatar.scale = Vector3.ONE
		subject.add_child(awoc_res.awoc_avatar_res.avatar)
	
"""namespace AWOC
{
	[Tool]
	public partial class MeshesPane : CenterPaneBase
	{ 
		[Export] FileDialog loadMeshDialog;
		[Export] Label filePathLabel;
		[Export] PackedScene meshContainerScene;
		[Export] HBoxContainer addMeshContainer;
		[Export] ColorRect meshListBackground;
		[Export] VBoxContainer meshListContainer;
		[Export] PackedScene meshPreviewScene;
		MeshPreview meshPreview;
		string[] meshList;

		void ShowMesh(string meshName, bool show)
		{
			if(show)
				meshList = AWOCHelper.AddElementToArray(meshName, meshList);
			else
				meshList = AWOCHelper.RemoveElementFromArray(meshName, meshList);

			if(meshList == null)
			{
				if(meshPreview != null)
				{
					meshPreview.QueueFree();
					meshPreview = null;
					awocEditor.currentPreviewNode = null;
				}
					
			}
			else
			{
				if(meshPreview == null)
				{
					meshPreview = meshPreviewScene.Instantiate<MeshPreview>();
					awocEditor.LoadPreview(meshPreview);
				}
				meshPreview.SetNewSubject(awocObj.awocAvatarRes.CreateAWOCAvatar(meshList));
			}
		}

		void PopulateMeshListContainer()
		{
			foreach(var child in meshListContainer.GetChildren())
			{
				child.QueueFree();
			}

			Dictionary<string, MeshInstance3D>.KeyCollection keys = awocObj.awocAvatarRes.sourceMeshList.Keys;
			foreach(string meshName in keys)
			{
				MeshContainer newMeshContainer = (MeshContainer)meshContainerScene.Instantiate();
				newMeshContainer.SetMeshName(meshName);
				newMeshContainer.ShowMesh += ShowMesh;
				meshListContainer.AddChild(newMeshContainer);
			}
			addMeshContainer.Visible = false;
			meshListBackground.Visible = true;
		}
		void _on_mesh_object_file_path_button_pressed()
		{
			loadMeshDialog.Visible = true;
		}
		
		void _on_load_mesh_dialog_file_selected(string path)
		{
			filePathLabel.Text = path;
			awocObj.awocAvatarRes = new AvatarRes(AWOCHelper.GetFileNameFromPath(path), GD.Load<PackedScene>(path));
			awocObj.SaveAWOC();
			PopulateMeshListContainer();
		}
	
		public override void InitPane(AWOCEditor awocEditor)
		{
			this.awocEditor = awocEditor;
			this.awocObj = awocEditor.awocObj;

			meshPreview = null;

			loadMeshDialog.Visible = false;
			loadMeshDialog.ClearFilters();
			loadMeshDialog.AddFilter("*.glb", "GL Transmission Format Binary file");
			loadMeshDialog.CurrentDir = "/";

			if(awocObj.awocAvatarRes == null)
			{
				addMeshContainer.Visible = true;
				meshListBackground.Visible = false;
			}
			else
			{
				awocObj.awocAvatarRes.InitAvatar();
				PopulateMeshListContainer();
			}
		}
	}
}


/*@tool
extends AWOCBasePane

@export var mesh_object_file_path_label: Label
@export var load_mesh_dialog: FileDialog
@export var add_meshes_container: HBoxContainer
@export var mesh_container: PackedScene
@export var mesh_list_container: VBoxContainer
@export var mesh_list_background: ColorRect

var preview_mesh_list: Array

func show_mesh(mesh_name: String):
	preview_mesh_list.append(mesh_name)
	awoc_editor.preview_awoc_meshes(preview_mesh_list)

func hide_mesh(mesh_name: String):
	preview_mesh_list.erase(mesh_name)
	awoc_editor.preview_awoc_meshes(preview_mesh_list)
	
func populate_mesh_list_container():
	if awoc_editor != null:
		if awoc_editor.awoc_obj.source_avatar_file == null:
			add_meshes_container.visible = true
			mesh_list_background.visible = false
			return
			
		add_meshes_container.visible = false
		mesh_list_background.visible = true
		
		for child in mesh_list_container.get_children():
			child.queue_free()
		for mesh_name in awoc_editor.awoc_obj.source_mesh_list:
			var new_mesh_container = mesh_container.instantiate()
			new_mesh_container.hide_mesh.connect(hide_mesh)
			new_mesh_container.show_mesh.connect(show_mesh)
			mesh_list_container.add_child(new_mesh_container)
			new_mesh_container.set_mesh_name(mesh_name)
	
func _ready():
	populate_mesh_list_container()
	load_mesh_dialog.visible = false
	load_mesh_dialog.visible = false
	load_mesh_dialog.clear_filters()
	load_mesh_dialog.add_filter("*.glb", "GL Transmission Format Binary file")
	load_mesh_dialog.current_dir = "/"

func _on_mesh_object_file_path_button_pressed():
	load_mesh_dialog.visible = true

func _on_load_mesh_dialog_file_selected(path):
	mesh_object_file_path_label.set_text(path)
	awoc_editor.awoc_obj.init_source_avatar(path)
	awoc_editor.save_current_awoc()
	populate_mesh_list_container()*/"""



