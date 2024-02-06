@tool
class_name AWOCSlotsRes extends Resource

@export var slots: Dictionary

func get_available_hide_slots(slot_name: String) -> PackedStringArray:
	var slots_list: PackedStringArray = PackedStringArray()
	for slot in slots:
		if slot_name != slot:
			var found: bool = false
			for a in slots[slot_name].size():
				if slot == slots[slot_name][a]:
					found = true
			if !found:
				slots_list.append(slot)
	return slots_list
	
func check_for_slot(slot_name: String, func_name: String) -> int:
	if slots == null:
		printerr("Slots dictionary in AWOCSlotRes has not been initilized\nAWOCSlotRes " + func_name)
		return AWOCError.SLOTS_NOT_INITILIZED
	if !slots.has(slot_name):
		printerr("Slot " + slot_name + " doesn't exist.\nAWOCSlotRes " + func_name)
		return AWOCError.SLOT_DOESNT_EXIST
	return AWOCError.SUCCESS
	
func add_slot(slot_name: String, overwrite: bool) -> int:
	if slots == null:
		printerr("Slots dictionary in AWOCSlotRes has not been initilized\nAWOCSlotRes add_slot")
		return AWOCError.SLOTS_NOT_INITILIZED
	if !overwrite and slots.has(slot_name):
		printerr("Slot " + slot_name + " already exists.\nAWOCSlotRes add_slot")
		return AWOCError.SLOT_EXISTS
		
	slots[slot_name] = PackedStringArray()
	if !slots.has(slot_name) or slots[slot_name] == null:
		printerr("There was an error creating a PackedStringArray for Slot " + slot_name + ".\nAWOCSlotRes add_slot")
		return AWOCError.ARRAY_NOT_CREATED	
	return AWOCError.SUCCESS

func rename_slot(slot_to_rename: String, new_name: String, overwrite: bool) -> int:
	var check_slot: int = check_for_slot(slot_to_rename, "rename_slot")
	if check_slot != AWOCError.SUCCESS:
		return check_slot
	if !overwrite and slots.has(new_name):
		return AWOCError.SLOT_EXISTS
	for slot in slots:
		if slots[slot] != null and slots[slot].size() > 0: 
			for a in slots[slot].size():
				if slots[slot][a] == slot_to_rename:
					slots[slot][a] = new_name
	slots[new_name] = slots[slot_to_rename]
	slots.erase(slot_to_rename)
	for a in slots[new_name].size():
		if slots[new_name][a] == new_name:
			slots[new_name].remove_at(a)
			break
	
	return AWOCError.SUCCESS

func delete_slot(slot_to_delete: String) -> int:
	var check_slot: int = check_for_slot(slot_to_delete, "delete_slot")
	if check_slot != AWOCError.SUCCESS:
		return check_slot
	slots.erase(slot_to_delete)
	#remove slot from all hide slot lists
	for slot in slots:
		for a in slots[slot].size():
			if slots[slot][a] == slot_to_delete:
				slots[slot].remove_at(a)
				break		
	return AWOCError.SUCCESS

func add_hide_slot(slot_name: String, hide_slot_name: String) -> int:
	var check_slot: int = check_for_slot(slot_name, "add_hide_slot")
	if check_slot != AWOCError.SUCCESS:
		return check_slot
	for hide_slot in slots[slot_name]:
		if hide_slot == hide_slot_name:
			return AWOCError.SUCCESS
	if slots[slot_name] == null:
		slots[slot_name] = PackedStringArray()	
	if slots[slot_name] == null:
		printerr("There was an error creating a PackedStringArray for Slot " + slot_name + ".\nAWOCSlotRes add_hide_slot")
		return AWOCError.ARRAY_NOT_CREATED	
	slots[slot_name].append(hide_slot_name)
	return AWOCError.SUCCESS
	
func rename_hide_slot(slot_name: String, hide_slot_name: String, new_name: String) -> int:
	var check_slot: int = check_for_slot(slot_name, "rename_hide_slot")
	if check_slot != AWOCError.SUCCESS:
		return check_slot
	for a in slots[slot_name].size():
		if slots[slot_name][a] == hide_slot_name:
			slots[slot_name][a] = new_name
			return AWOCError.SUCCESS
	printerr("Hide slot " + hide_slot_name + " does not exist.\nAWOCSlotRes rename_hide_slot")
	return AWOCError.HIDE_SLOT_DOESNT_EXIST

func delete_hide_slot(slot_name: String, hide_slot_name) -> int:
	var check_slot: int = check_for_slot(slot_name, "delete_hide_slot")
	if check_slot != AWOCError.SUCCESS:
		return check_slot
	for a in slots[slot_name].size():
		if slots[slot_name][a] == hide_slot_name:
			slots[slot_name].remove_at(a)
			return AWOCError.SUCCESS
	return AWOCError.HIDE_SLOT_DOESNT_EXIST
