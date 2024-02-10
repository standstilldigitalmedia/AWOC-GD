extends Node3D
@export var main_cam: Camera3D
@export var target: Node3D
@export var awoc: AWOCRes

# Called when the node enters the scene tree for the first time.
func _ready():
	awoc.avatar_res.deserialize_avatar(["Feet", "Hands", "Legs", "Torso"])
	target.add_child(awoc.avatar_res.avatar)
