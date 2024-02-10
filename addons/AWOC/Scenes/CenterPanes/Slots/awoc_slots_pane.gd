@tool
extends AWOCCenterPaneBase

@export var slot_container: PackedScene #the scene to instantiate for each slot and parent to slotsScrollContainer
@export var add_slot_name_edit: LineEdit #Line edit for entering a new slot name
@export var slots_scroll_container: VBoxContainer #The container new SlotContainers will be parented to
@export var confirm_duplicate_slot_dialog: ConfirmationDialog #Displayed when a slot is being created with the same 
														#name as an exisiting slot. Overwrites the existing 
														#slot if confirmed
														
func populate_slots_container():
	for slot in slots_scroll_container.get_children():
		slot.queue_free()
		
	for slot in awoc_res.slots_res.slots:
		var container = slot_container.instantiate()
		container.set_slot_name(slot, awoc_res)
		container.populate.connect(populate_slots_container)
		slots_scroll_container.add_child(container)
		
func _on_add_slot_button_pressed():
	var new_slot_name: String = add_slot_name_edit.text
	if awoc_res.slots_res.slots.has(new_slot_name):
		confirm_duplicate_slot_dialog.title = "Overwrite " + add_slot_name_edit.text + "?"
		confirm_duplicate_slot_dialog.dialog_text = "A slot with this name already exists. Would you like to overwrite it?"
		confirm_duplicate_slot_dialog.visible = true
	else:
		var error: int = awoc_res.slots_res.add_slot(new_slot_name,false)
		if error == AWOCError.SUCCESS:
			add_slot_name_edit.text = ""
			awoc_res.save_awoc()
			populate_slots_container()
		elif error == AWOCError.ELEMENT_EXISTS:
			printerr("You shouldn't be getting this error.\nAWOCSlotsPane _on_add_slot_button_pressed")
		
		
func _on_confirm_duplicate_slot_dialog_confirmed():
	var error: int = awoc_res.slots_res.add_slot(add_slot_name_edit.text,true)
	if error == AWOCError.SUCCESS:
		add_slot_name_edit.text = ""
		awoc_res.save_awoc()
		populate_slots_container()
		
func init_pane(editor: AWOCEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
	populate_slots_container()
