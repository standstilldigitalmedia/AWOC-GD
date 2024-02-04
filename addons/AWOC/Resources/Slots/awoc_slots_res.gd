@tool
class_name AWOCSlotsRes extends Resource

@export var slots: Dictionary

const SLOTS_NOT_INITILIZED: int = 1
const SLOT_EXISTS: int = 2
const SLOT_DOESNT_EXIST: int = 3
const HIDE_SLOT_EXISTS: int = 4
const HIDE_SLOT_DOESNT_EXIST: int = 5
const ARRAY_NOT_CREATED = 6
const SLOT_NOT_ADDED = 7
const SUCCESS = 10

static func get_error(error_code: int, slot_name: String, hide_slot_name: String="") -> String:
	match error_code:
		SLOTS_NOT_INITILIZED:
			return "The slots dictionary in the slots resource has not been initilized."
		SLOT_EXISTS:
			return "The slot " + slot_name + " already exists."
		SLOT_DOESNT_EXIST:
			return "The slot " + slot_name + " does not exist."
		HIDE_SLOT_EXISTS:
			return "The hide slot " + hide_slot_name + " already exists."
		HIDE_SLOT_DOESNT_EXIST:
			return "The hide slot " + hide_slot_name + " doesn't exist."
		ARRAY_NOT_CREATED:
			return "A new hide slots array could not be created."
		SLOT_NOT_ADDED:
			return "The slot " + slot_name + " could not be added to the slot dictionary."
	return ""

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
	
func add_slot(slot_name: String, overwrite: bool) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !overwrite and slots.has(slot_name):
		return SLOT_EXISTS
		
	slots[slot_name] = PackedStringArray()
	if slots[slot_name] == null:
		return ARRAY_NOT_CREATED
	#make sure the new slot got added
	if !slots.has(slot_name) or slots[slot_name] == null:
		return SLOT_NOT_ADDED
	return SUCCESS

func rename_slot(slot_to_rename: String, new_name: String) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_to_rename):
		return SLOT_DOESNT_EXIST
	slots[new_name] = slots[slot_to_rename]
	slots.erase(slot_to_rename)
	return SUCCESS

func delete_slot(slot_to_delete: String) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_to_delete):
		return SLOT_DOESNT_EXIST
	slots.erase(slot_to_delete)
	#remove slot from all hide slot lists
	for slot in slots:
		for a in slots[slot].size():
			if slots[slot][a] == slot_to_delete:
				slots[slot].remove_at(a)
				break		
	return SUCCESS

func add_hide_slot(slot_name: String, hide_slot_name: String) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_name):
		return SLOT_DOESNT_EXIST
	for hide_slot in slots[slot_name]:
		if hide_slot == hide_slot_name:
			return SUCCESS
	if slots[slot_name] == null:
		slots[slot_name] = PackedStringArray()	
	if slots[slot_name] == null:
		return ARRAY_NOT_CREATED	
	slots[slot_name].append(hide_slot_name)
	return SUCCESS
	
func rename_hide_slot(slot_name: String, hide_slot_name: String, new_name: String) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_name):
		return SLOT_DOESNT_EXIST
	for a in slots[slot_name].size():
		if slots[slot_name][a] == hide_slot_name:
			slots[slot_name][a] = new_name
			return SUCCESS
	return HIDE_SLOT_DOESNT_EXIST

func delete_hide_slot(slot_name: String, hide_slot_name) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_name):
		return SLOT_DOESNT_EXIST
	for a in slots[slot_name].size():
		if slots[slot_name][a] == hide_slot_name:
			slots[slot_name].remove_at(a)
			return SUCCESS
	return HIDE_SLOT_DOESNT_EXIST
			
func slot_exisits(slot_name: String) -> bool:
	if slots != null and slots.has(slot_name):
		return true
	return false

func reset_slot(slot_name: String) -> int:
	if slots == null:
		return SLOTS_NOT_INITILIZED
	if !slots.has(slot_name):
		return SLOT_DOESNT_EXIST
	slots[slot_name] = PackedStringArray()
	return SUCCESS
