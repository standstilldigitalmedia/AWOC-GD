@tool
class_name AWOCSlotContainer extends Node

signal populate()

@export var slot_button: Button #the main slot button that hides and shows the slotControlsContainer
@export var slot_controls_container: HBoxContainer #the container that holds the slotNameEdit, save button, delete button, and show and hide buttons
@export var slot_name_edit: LineEdit #a line edit for changing the slot name
@export var show_button: Button #when clicked, hides itself and shows hideButton and also shows hideSlotContainer
@export var hide_button: Button #when clicked, hides itself and shows showButton and also hides hideSlotContainer
@export var hide_slot_container: ColorRect #the container that holds the hideSlotControls. It is hidden or shown when the show and hide buttons are pressed
@export var hide_slot_select: OptionButton #each option is slot you can have hidden when this slot is equipped
@export var add_hide_slot_button: Button
@export var hide_slot_scroll_container: VBoxContainer #the container that holds all the hide slot controls
@export var confirm_save_dialog: ConfirmationDialog #displayed when the save button is pressed. If confirmed, the new slot name is saved
@export var confirm_overwrite_dialog: ConfirmationDialog
@export var confirm_delete_dialog: ConfirmationDialog #displayed when the delete button is pressed. If confirmed, the new slot is deleted
@export var hide_slot_container_scene: PackedScene #the scene to instantiate for each hide slot and parent to hideSlotScrollContainer

@export var slot_name: String #The AWOCSlot this container managages
@export var slots_to_hide: Array
var awoc_res: AWOCRes

func populate_hide_slot_select():
	var hide_slots: PackedStringArray = awoc_res.slots_res.get_available_hide_slots(slot_name)
	hide_slot_select.clear()
	for hide_slot in hide_slots:
		hide_slot_select.add_item(hide_slot)
	hide_slot_select.selected = -1

func delete_hide_slot(hide_slot_name: String):
	var error: int = awoc_res.slots_res.delete_hide_slot(slot_name,hide_slot_name)
	if error == AWOCError.SUCCESS:
		awoc_res.save_awoc()
		populate_hide_slot_select()
		hide_slot_select.selected = -1

func populate_hide_slot_container():
	for child in hide_slot_scroll_container.get_children():
		child.queue_free()
	for hide_slot: String in awoc_res.slots_res.slots[slot_name]:
		var hide_slot_container = hide_slot_container_scene.instantiate()
		hide_slot_container.set_hide_slot_name(hide_slot)
		hide_slot_container.delete_hide_slot.connect(delete_hide_slot)
		hide_slot_scroll_container.add_child(hide_slot_container)
	
# <summary>
# Sets awocSlot for this slot, and sets the text of slotButton and slotNameEdit to this slot's slotName
# </summary>
# <param name="awocSlot">The AWOCSlot this container will manage</param>
# <returns>void</returns>
func _on_slot_button_toggled(toggled_on: bool):
	slot_controls_container.visible = toggled_on
	hide_slot_container.visible = false
	show_button.visible = true
	hide_button.visible = false
	
func set_slot_name(s_name: String, a_res: AWOCRes):
	slot_name = s_name;
	slot_button.text = s_name;
	slot_name_edit.text = s_name;
	awoc_res = a_res
	_on_slot_button_toggled(false)
	populate_hide_slot_select()
	populate_hide_slot_container()
	add_hide_slot_button.disabled = true
	hide_slot_select.select(-1)


func _on_save_button_pressed():
	if awoc_res.slots_res.slots.has(slot_name_edit.text):
		confirm_overwrite_dialog.title = "Overwrite " + slot_name + "?"
		confirm_overwrite_dialog.dialog_text = "A slot named " + slot_name_edit.text + " already exists. Do you want to overwrite it? This can not be undone."
		confirm_overwrite_dialog.visible = true
	else:
		confirm_save_dialog.title = "Rename " + slot_name + "?"
		confirm_save_dialog.dialog_text = "Are you sure you want to rename " + slot_name + " to " + slot_name_edit.text + "? This can not be undone."
		confirm_save_dialog.visible = true


func _on_delete_button_pressed():
	confirm_delete_dialog.title = "Delete " + slot_name + "?"
	confirm_delete_dialog.dialog_text = "Are you sure you want to delete " + slot_name +"? This can not be undone."
	confirm_delete_dialog.visible = true


func _on_show_button_pressed():
	hide_slot_container.visible = true
	show_button.visible = false
	hide_button.visible = true


func _on_hide_button_pressed():
	hide_slot_container.visible = false
	show_button.visible = true
	hide_button.visible = false


func _on_hide_slot_select_item_selected(index):
	add_hide_slot_button.disabled = false


func _on_add_hide_slot_button_pressed():
	add_hide_slot_button.disabled = true
	var selected_hide_slot: String = hide_slot_select.get_item_text(hide_slot_select.get_selected_id())
	var error: int = awoc_res.slots_res.add_hide_slot(slot_name, selected_hide_slot)
	if error == AWOCError.SUCCESS:
		awoc_res.save_awoc()
		populate_hide_slot_select()
		populate_hide_slot_container()

func _on_confirm_save_dialog_confirmed():
	var error: int = awoc_res.slots_res.rename_slot(slot_name, slot_name_edit.text, false)
	if error == AWOCError.SUCCESS:
		awoc_res.save_awoc()
		set_slot_name(slot_name_edit.text, awoc_res)
	if error == AWOCError.SLOT_EXISTS:
		printerr("Should not get this error.\nAWOCSlotContainer _on_confirm_save_dialog_confirmed")
	populate.emit()
	
func _on_confirm_delete_dialog_confirmed():
	var error: int = awoc_res.slots_res.delete_slot(slot_name)
	if error == AWOCError.SUCCESS:
		awoc_res.save_awoc()
		populate.emit()
		queue_free()
		
func _on_confirm_overwrite_dialog_confirmed():
	var error: int = awoc_res.slots_res.rename_slot(slot_name, slot_name_edit.text, true)
	if error == AWOCError.SUCCESS:
		awoc_res.save_awoc()
		queue_free()
	populate.emit()
