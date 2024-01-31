@tool
extends AwocCenterPaneBase

@export var slot_container: PackedScene #the scene to instantiate for each slot and parent to slotsScrollContainer
@export var add_slot_name_edit: LineEdit #Line edit for entering a new slot name
@export var slots_scroll_container: VBoxContainer #The container new SlotContainers will be parented to
@export var confirm_duplicate_slot_dialog: ConfirmationDialog #Displayed when a slot is being created with the same 
														#name as an exisiting slot. Overwrites the existing 
														#slot if confirmed
														
func populate_slots_container():
	for slot in slots_scroll_container.get_children():
		slot.queue_free()
		
	for slot in awoc_res.awoc_slots_res.slots:
		var container = slot_container.instantiate()
		container.set_slot_name(slot, awoc_res)
		container.populate.connect(populate_slots_container)
		slots_scroll_container.add_child(container)
		
func _on_add_slot_button_pressed():
	var error: int = awoc_res.awoc_slots_res.add_slot(add_slot_name_edit.text,false)
	if error == AwocSlotsRes.SUCCESS:
		add_slot_name_edit.text = ""
		awoc_res.save_awoc()
		populate_slots_container()
	elif error == AwocSlotsRes.SLOT_EXISTS:
		confirm_duplicate_slot_dialog.title = "Overwrite " + add_slot_name_edit.text + "?"
		confirm_duplicate_slot_dialog.dialog_text = "A slot with this name already exists. Would you like to overwrite it?"
		confirm_duplicate_slot_dialog.visible = true
	else:
		push_error(AwocSlotsRes.get_error(error,add_slot_name_edit.text))
		
func _on_confirm_duplicate_slot_dialog_confirmed():
	var error: int = awoc_res.awoc_slots_res.add_slot(add_slot_name_edit.text,true)
	if error == AwocSlotsRes.SUCCESS:
		add_slot_name_edit.text = ""
		awoc_res.save_awoc()
		populate_slots_container()
	else:
		push_error(AwocSlotsRes.get_error(error,add_slot_name_edit.text))
		
func init_panel(editor: AwocEditor):
	awoc_editor = editor
	awoc_res = editor.awoc_res
	populate_slots_container()
		
# <summary>
# All of the children in slots_scroll_container are freed before looping through each AwocSlotRes in 
# awoc_res.awoc_slots_res.slot_containers. For each AwocSlotContainerRes, a dictionary containing the names 
# of all the slots in awoc_res.awoc_slots_res.slot_containers is created and used
# to initilize a new AWOCSlotContainer. Listeners for all of the signals the new SlotConainer will emit are assigned
# before adding the new SlotContainer as a child of slotsScrollContainer.
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
"""func populate_slots_container()
	if awoc_res != null:
		for slot_container in slots_scroll_container.get_children():
			slot_container.queue_free()

		if awoc_res.awocSlotsRes.slotContainers != null:
		{
			foreach(SlotContainerRes slotContainerRes in awocObj.awocSlotsRes.slotContainers)
			{
				Dictionary<string,string> slotNameDictionary = new Dictionary<string, string>();
				foreach(SlotContainerRes innerSlot in awocObj.awocSlotsRes.slotContainers)
				{
					slotNameDictionary.Add(innerSlot.slotName,innerSlot.slotName);
				}
				SlotContainer container = slotContainer.Instantiate<SlotContainer>();
				container.InitSlotContainer(slotContainerRes, slotNameDictionary);
				container.RenameSlot += OnRenameSlot;
				container.DeleteSlot += OnDeleteSlot;
				container.DeleteHideSlot += OnDeleteHideSlot;
				container.AddHideSlot += OnAddHideSlot;
				slotsScrollContainer.AddChild(container);
			}
		}
	}
}

# <summary>
# Fired in response to the AddSlot button in a this pane being pressed, if the name being added is
# the same as another slot, a confirm_duplicate_slot_dalog is displayed to confirm overwriting the existing slot.
# If no duplicate is found, a new AwocSlotRes is created and added to the awoc_res.AwocSlotsRes
# array. The awoc is then saved and the slots_container is repopulated.
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_add_slot_button_pressed():
	if add_slot_name_edit.text.length() > 3 and awoc_res != null:
		if awoc_res.awoc_slots_res.slot_exists(add_slot_name_edit.text):
			confirm_duplicate_slot_dialog.title = "Overwrite " + add_slot_name_edit.text + "?"
			confirm_duplicate_slot_dialog.dialog_text = "A slot with this name already exists. Would you like to overwrite it?"
			confirm_duplicate_slot_dialog.visible = true
			return

		awoc_res.awoc_slots_res.add_slot(add_slot_name_edit.text)
		add_slot_name_edit.text = ""
		awoc_res.save_awoc()
		populate_slots_container()

# <summary>
# In response to the confirmDuplicateSlotDialog being confirmed, calls
# awocObj.awocSlotsRes.ResetSlot(addSlotNameEdit.Text) and awocObj is saved to disk.
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
void _on_confirm_duplicate_slot_dialog_confirmed()
{
	awocObj.awocSlotsRes.ResetSlot(addSlotNameEdit.Text);
	awocObj.SaveAWOC();
}

# <summary>
# Overridden from CenterPaneBase, awocEditor and awocObj are set. If awocObj.awocSlotsRes is null, a 
# new AWOCSlotRes is created and assigned to awocObj.awocSlotsRes. Finally, SlotsContainer is populated. 
# </summary>
# <param name="awocEditor">The main controller for the AWOC editor window</param>
# <returns>void</returns>
public override void InitPane(AWOCEditor awocEditor)
{
	this.awocEditor = awocEditor;
	awocObj = awocEditor.awocObj;
	if(awocObj.awocSlotsRes == null)
	{
		awocObj.awocSlotsRes = new SlotsRes();
	}
	PopulateSlotsContainer();
}"""
