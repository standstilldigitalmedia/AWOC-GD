@tool
class_name AwocCenterPaneBase extends Node

@export var awoc_editor: AwocEditor
@export var awoc_res: AwocRes

func init_panel(editor: AwocEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
