@tool
class_name AWOCEditor extends Control

# The various panes that will be loaded into the center of the editor window
@export var welcome_pane: PackedScene
@export var new_awoc_pane: PackedScene
@export var slots_pane: PackedScene
@export var meshes_pane: PackedScene
@export var materials_pane: PackedScene
@export var recipes_pane: PackedScene
@export var wardrobes_pane: PackedScene
@export var animations_pane: PackedScene
# The various preview panes that will be loaded into the right side of the editor window
@export var mesh_preview_pane: PackedScene
@export var material_preview_pane: PackedScene

# Each button corresponds to a pane above. When clicked, the old center pane is released and the 
# new pane is added 
@export var slots_button: Button
@export var meshes_button: Button
@export var materials_button: Button
@export var recipes_button: Button
@export var wardrobes_button: Button
@export var animations_button: Button

# The right pane where preview panes are parented
@export var rightPane: ColorRect
# The center pane where the regular panes are parented
#@export var mainContainer: HBoxContainer

@export var awoc_res: AWOCRes
var current_pane: AWOCCenterPaneBase
#var currentPreviewNode: BasePreviewPane

# <summary>
# Set Disabled on all of the buttons on in the left naviagation pane
# to the value in the parameter disable
# </summary>
# <param name="disable">A boolean that either enables or disables the buttons in the left navigation pane/param>
# <returns>void</returns>
func disable_left_nav(disable: bool):
	slots_button.disabled = disable
	meshes_button.disabled = disable
	animations_button.disabled = disable
	materials_button.disabled = disable
	recipes_button.disabled = disable
	wardrobes_button.disabled = disable

# <summary>
# Cleans up the AWOC editor window and then loads the pane specified in the paramater pane and parents it to the
# pane in the center of the AWOC editor window
# </summary>
# <param name="pane">The pane to parent to the pane in the center of the AWOC editor window</param>
# <returns>void</returns>
func load_pane(pane: PackedScene):
	#if loading welcomePane, disable the buttons in the left navigation
	#otherwise, enable them
	if pane == welcome_pane or pane == new_awoc_pane:
		disable_left_nav(true)
	else:
		disable_left_nav(false)

	"""if(currentPreviewNode != null)
		currentPreviewNode.QueueFree();
	currentPreviewNode = null;"""

	if current_pane != null:
		current_pane.queue_free()

	#now that all the old stuff has been freed, the new pane can be instantiated and parented to the right pane	
	current_pane = pane.instantiate()
	current_pane.init_pane(self)
	rightPane.add_child(current_pane)

# <summary>
# Loads the welcome_pane in response to the WelcomeButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_welcome_button_pressed():
	load_pane(welcome_pane)

# <summary>
# Loads the slots_pane in response to the SlotsButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_slots_button_pressed():
	load_pane(slots_pane)

# <summary>
# Loads the meshes_pane in response to the MeshesButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_meshes_button_pressed():
	load_pane(meshes_pane)

# <summary>
# Loads the materials_pane in response to the MaterialsButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_materials_button_pressed():
	load_pane(materials_pane)

# <summary>
# Loads the recipes_pane in response to the RecipesButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_recipes_button_pressed():
	load_pane(recipes_pane)

# <summary>
# Loads the wardrobes_pane in response to the WardrobesButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_wardrobes_button_pressed():
	load_pane(wardrobes_pane)

# <summary>
# Loads the animations_pane in response to the AnimationsButton being pressed
# </summary>
# <param name="none">none</param>
# <returns>void</returns>
func _on_animations_button_pressed():
	load_pane(animations_pane)

func _ready():
	load_pane(welcome_pane)
