@tool
class_name AWOCCenterPaneBase extends Node

@export var awoc_editor: AWOCEditor
@export var awoc_res: AWOCRes

func init_pane(editor: AWOCEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
