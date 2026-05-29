extends CanvasLayer

# Attach to the root CanvasLayer of victory.tscn

## Main menu scene path
@export var menu_scene_path : String = "uid://cb6gbe8qaands"


func _ready() -> void:
	get_tree().paused = false

	# ── Play victory music via AudioManager ───────────────────────────────────
	var audio_mgr := get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_music("menu", true)
	else:
		push_warning("Victory: AudioManager autoload not found.")

	# ── Wire buttons ──────────────────────────────────────────────────────────
	var btn_menu := _find_button("Menu")
	var btn_quit := _find_button("Quit")

	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)
	else:
		push_error("Victory: 'Menu' button not found.")

	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)
	else:
		push_error("Victory: 'Quit' button not found.")

	# ── Same button SFX as the main menu ─────────────────────────────────────
	_connect_button_sounds([btn_menu, btn_quit])


# Identical to menu.gd — plays click on press, hover on mouse_entered
func _connect_button_sounds(buttons: Array) -> void:
	for btn in buttons:
		if btn == null:
			continue
		btn.pressed.connect(func(): AudioManager.play_sfx("button_click"))
		btn.mouse_entered.connect(func(): AudioManager.play_sfx("button_hover"))


func _find_button(target_name: String) -> Button:
	return _search(self, target_name) as Button

func _search(node: Node, target_name: String) -> Node:
	if node.name == target_name and node is Button:
		return node
	for child in node.get_children():
		var result := _search(child, target_name)
		if result:
			return result
	return null


func _on_menu_pressed() -> void:
	AudioManager.play_music("menu", true)
	get_tree().change_scene_to_file(menu_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
