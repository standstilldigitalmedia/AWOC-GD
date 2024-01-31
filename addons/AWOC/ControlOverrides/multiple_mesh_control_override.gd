@tool
extends Control

func _can_drop_data(position, data):
	return data["type"] == "files"

func _drop_data(position, data):
	self.text = data["files"][0]
