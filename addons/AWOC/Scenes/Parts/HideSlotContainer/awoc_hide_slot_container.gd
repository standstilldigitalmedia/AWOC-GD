@tool
class_name AwocHideSlotContainer extends Node

signal delete_hide_slot(hs_name: String) # In response to the ConfirmDeleteDialog being confirmed, this signal is emitted for SlotContainer to handle

@export var hide_slot_label: Label #the label that shows the name of this hide slot
@export var confirm_delete_dialog: ConfirmationDialog #displayed when the delete button is pressed. Confirms if this hide slot should be deleted
var hide_slot_name: String #the name of the hide slot that this HideSlotContainer manages

# <summary>
# Sets the name of this hide slot on both the hide slot label and in the property hide_slot_name
# </summary>
# <param name="hs_name">The name of the new hide slot</param>
# <returns>void</returns>
func set_hide_slot_name(hs_name: String):
	hide_slot_name = hs_name;
	hide_slot_label.text = hs_name;
	confirm_delete_dialog.visible = false;

# <summary>
# Configures the confirm_delete_dialog and then displays it in response to the delete button being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_delete_hideslot_button_pressed():
	confirm_delete_dialog.title = "Delete " + hide_slot_name + "?"
	confirm_delete_dialog.dialog_text = "Are you sure you wish to delete " + hide_slot_name + "? This can not be undone."
	confirm_delete_dialog.visible = true

# <summary>
# Emits the delete_hide_slot signal and then frees itself
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_confirm_delete_hide_slot_dialog_confirmed():
	delete_hide_slot.emit(hide_slot_name)
	queue_free()
