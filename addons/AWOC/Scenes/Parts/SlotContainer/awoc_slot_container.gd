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

func delete_hide_slot(hide_slot_name: String):
	var error: int = awoc_res.slots_res.delete_hide_slot(slot_name,hide_slot_name)
	if error == AWOCSlotsRes.SUCCESS:
		awoc_res.save_awoc()
		populate_hide_slot_select()
		hide_slot_select.selected = -1
	else:
		push_error(AWOCSlotsRes.get_error(error,hide_slot_name))

func populate_hide_slot_container():
	for child in hide_slot_scroll_container.get_children():
		child.queue_free()
	for hide_slot: String in awoc_res.slots_res.slots[slot_name]:
		print(hide_slot + " hide slot")
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
	if error == AWOCSlotsRes.SUCCESS:
		awoc_res.save_awoc()
		populate_hide_slot_select()
		populate_hide_slot_container()
	else:
		push_error(AWOCSlotsRes.get_error(error,selected_hide_slot))

func _on_confirm_save_dialog_confirmed():
	var error: int = awoc_res.slots_res.rename_slot(slot_name, slot_name_edit.text)
	if error == AWOCSlotsRes.SUCCESS:
		awoc_res.save_awoc()
		set_slot_name(slot_name_edit.text, awoc_res)
	else:
		push_error(AWOCSlotsRes.get_error(error,slot_name))
	
func _on_confirm_delete_dialog_confirmed():
	var error: int = awoc_res.slots_res.delete_slot(slot_name)
	if error == AWOCSlotsRes.SUCCESS:
		awoc_res.save_awoc()
		populate.emit()
		queue_free()
	else:
		push_error(AWOCSlotsRes.get_error(error,slot_name))
	


"""# <summary>
# Clears hideSlotSelect and then loops through all of the keys in avaliableSlotsToHide and adds them to the 
# hideSlotSelect option button. Finally, the first option in hideSlotSelect is selected
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func populate_hide_slot_select():
	if avaliable_slots != null :
		hide_slot_select.clear()
		for slot in avaliable_slots:
			if slot != slot_name:
				hide_slot_select.add_item(slot)
		if hide_slot_select.item_count > 0:
			hide_slot_select.select(-1)
			
# <summary>
# Adds the paramater deleteSlotName to availableSlotsToHide, removes deleteSlotName from hideSlotsArray,
# populates the HideSlotSelect option button, and emits the DeleteHideSlot signal for SlotsPane to handle
# in response to HideSlotContainer emitting the Delete signal
# </summary>
# <param name="deleteSlotName">The name of the hide slot to remove</param>
# <returns>void</returns>
func on_delete_hide_slot(delete_slot_name: String):
	if !avaliable_slots.has(delete_slot_name):
		avaliable_slots[delete_slot_name] = delete_slot_name
		
	if slots_to_hide[delete_slot_name] == delete_slot_name:
		slots_to_hide.erase(delete_slot_name)
			
	populate_hide_slot_select();
	delete_hide_slot.emit(slot_name,delete_slot_name)
			
# <summary>
# Frees all children of hide_slot_scroll_container and then loops through all the hide slots in 
# slots_to_hide and spawns a AwocHideSlotContainer and parents it to hide_slot_scroll_container
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func populate_hide_slot_container():
	if slots_to_hide != null:
		# get rid of all of HideSlotScrollContainer's children before adding more
		for child in hide_slot_scroll_container.get_children():
			child.queue_free();

		for hide_slot in slots_to_hide:
			# instantiate a new HideSlotContainer
			var new_hide_slot: AwocHideSlotContainer = hide_slot_container_scene.instantiate()
			
			new_hide_slot.delete_hide_slot.connect(on_delete_hide_slot)
			# set the new HideSlotContainer's hide slot name
			new_hide_slot.set_hide_slot_name(hide_slot);
			#parent the new HideSlotContainer to hideSlotScrollContainer
			hide_slot_scroll_container.add_child(new_hide_slot)
			
# <summary>
# Shows or hides the main controls for this slot based on the value of the parameter named show
# </summary>
# <param name="show">A boolean used to set the visibility of this slot's main controls</param>
# <returns>void</returns>
func show_controls(show: bool):
	slot_controls_container.visible = show;
	hide_slot_container.visible = show;

# <summary>
# Loops through all the keys in availableSlotsToHide and all the strings in hideSlotsArray, looking for matches.
# If a match is found, it is removed from availableSlotsToHide
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func init_available_alots_to_hide():
	if avaliable_slots != null and slots_to_hide != null:
		for available_slot in avaliable_slots:
			if available_slot == slot_name:
				avaliable_slots.erase(available_slot)
			else:
				for hide_slot in slots_to_hide:
					if available_slot == hide_slot:
						avaliable_slots.erase(available_slot)

# <summary>
# Takes care of initilizing this SlotContainer with the paramaters provided
# </summary>
# <param name="awocSlot">The AWOCSlot this SlotContainer will manage</param>
# <param name="availableSlotsToHide">All of the slots in this AWOC except for the slot in awocSlot</param>
# <returns>void</returns>
func init_slot_container(avail_slots: Dictionary):
	avaliable_slots = avail_slots
	#slots_to_hide = slot_container.hideSlots

	confirm_save_dialog.visible = false
	confirm_delete_dialog.visible = false
	add_hide_slot_button.disabled = true

	show_controls(false)
	init_available_alots_to_hide()
	#set_slot_name(slot_container.slotName)	
	populate_hide_slot_select()
	populate_hide_slot_container()
	
		
# <summary>
# Shows or hides this slot's main controls and hide slot controls in response to the main slot button
# being pressed. Also shows showButton and hides hideButton
# </summary>
# <param name="buttonPressed">A boolean representing whether the button was toggled on or toggled off</param>
# <returns>void</returns>
func _on_slot_button_toggled(buttonPressed: bool):
	slot_controls_container.visible = buttonPressed;
	hide_slot_container.visible = false;
	show_button.visible = true;
	hide_button.visible = false;

# <summary>
# Hides showButton, shows hideButton, shows hideSlotContainer and populates hideSlotSelect with all 
# of this slot's hide slots in response to showButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_show_button_pressed():
	show_button.visible = false
	hide_button.visible = true
	hide_slot_container.visible = true
	populate_hide_slot_select()

# <summary>
# Shows show_button, hides hide_button, and hides hide_slot_container
# in response to hide_button being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_hide_button_pressed():
	show_button.visible = true;
	hide_button.visible = false;
	hide_slot_container.visible = false;

# <summary>
# Congfigures confirm_save_dialog and then displays it in response to the save button being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_save_button_pressed():
	if slot_name_edit.text.length() > 2:
		confirm_save_dialog.title = "Rename " + slot_name + "?";
		confirm_save_dialog.dialog_text = "Are you sure you wish to rename " + slot_name + "? This can not be undone.";
		confirm_save_dialog.visible = true;

# <summary>
# Congfigures confirm_delete_dialog and then displays it in response to the delete button being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_delete_button_pressed():
	confirm_delete_dialog.title = "Delete " + slot_name + "?";
	confirm_delete_dialog.dialog_text = "Are you sure you wish to delete " + slot_name + "? This can not be undone.";
	confirm_delete_dialog.visible = true;
	
# <summary>
# Emits the Delete signal for slot_pane to handle and then frees itself in response to confirm_delete_dialog
# being confirmed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_confirm_delete_dialog_confirmed():
	delete_slot.emit(slot_name)
	queue_free()

# <summary>
# Emits the rename_slot signal for slot_pane to handle, sets the new name in awoc_slot.slot_name, 
# and calls SetSlot to set the label text and edit text in response to the save button being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_confrim_save_dialog_confirmed():
	rename_slot.emit(slot_name, slot_name_edit.text)
	set_slot_name(slot_name_edit.text);
	
# <summary>
# Adds the selected slot name in hide_slot_select to slots_to_hide, removes the slot name in hide_slot_select from
# avaliable_slots, populates the hide_slot_container and hide_slot_select and then emits the add_hide_slot signal
# for slot_pane to handle
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_add_hide_slot_button_pressed():
	add_hide_slot_button.disabled = true
	var selected_slot: String = hide_slot_select.get_item_text(hide_slot_select.get_selected_id())
	slots_to_hide[selected_slot] = selected_slot
	if avaliable_slots.has(selected_slot):
		avaliable_slots.erase(selected_slot)
	populate_hide_slot_container()
	populate_hide_slot_select()
	add_hide_slot.emit(slot_name, selected_slot)
	
func _on_hide_slot_select_item_selected(index: int):
	if index >= 0:
		add_hide_slot_button.disabled = false
	else:
		add_hide_slot_button.disabled = true
"""


