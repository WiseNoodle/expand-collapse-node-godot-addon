@tool
extends EditorPlugin

# Made by WiseNoodle
# Credit to helloadam for his help

func _get_scene_tree_control(base: Node) -> Tree:
	if base.name == "Scene":
		var tree = null
		for c in base.get_children(true):
			if c.name.contains("SceneTreeEditor"):
				return c.get_child(0)
	for child in base.get_children():
		var tree = _get_scene_tree_control(child)
		if tree != null:
			return tree
	return null

func _get_editor_scene_tree_item(path: String, parent: TreeItem = null):
	if parent == null:
		parent = _get_scene_tree_control(get_editor_interface().get_base_control()).get_root()
	var path_parts = path.split("/")
	var first_part = path_parts[0]
	var next_parts = null
	if len(path_parts) > 1:
		next_parts = "/".join(path_parts.slice(1))
	if first_part == ".":
		return parent
	for child in parent.get_children():
		if child.get_text(0) == first_part:
			if next_parts == null:
				return child
			else:
				return _get_editor_scene_tree_item(next_parts, child)
	return null

var can_press : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if shortcut and shortcut.matches_event(event):
		if event.is_pressed() and can_press:
			can_press = false
			var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
			if selected_nodes.size() == 1:
				var selected_node = selected_nodes[0]
				var path_in_scene = get_editor_interface().get_edited_scene_root().get_path_to(selected_node)
#				print("selected node: ",path_in_scene) # DEBUG
				var item: TreeItem = _get_editor_scene_tree_item(path_in_scene)
				item.collapsed = !item.collapsed
				
			elif selected_nodes.size() > 1: # Selected more than 1 node
#				print("User tried expanding ", selected_nodes.size()," nodes. That's too many!") # DEBUG
				return
			elif selected_nodes.size() < 1: # Selected less than 1 node
#				print("User tried expanding ", selected_nodes.size()," nodes. Please only select 1") # DEBUG
				return
			else:
				return
		if event.is_released() and !can_press:
			can_press = true

var shortcut := _get_or_set_shortcut()

const PLUGIN_ID := "expand-collapse-node-plugin"
const PLUGIN_PATH := "addons/"+PLUGIN_ID

static func _get_or_set_shortcut() -> Shortcut:
	var key := PLUGIN_PATH + "/shortcut"
	if not ProjectSettings.has_setting(key):
		var default_shortcut := preload("./default_shortcut.tres")
		var path := default_shortcut.resource_path
		var property_info := {
			"name": key,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres" 
		}
		# store path instead of resource itself
		ProjectSettings.set_setting(key, path)
		ProjectSettings.add_property_info(property_info)
	var shortcut_path: String = ProjectSettings.get_setting(key)
	if shortcut_path == "":
		return null
	var loaded_shortcut: Shortcut = load(shortcut_path)
	return loaded_shortcut
