extends Control

@onready var main_menu       : VBoxContainer = $MainMenu
@onready var new_game_panel  : VBoxContainer = $NewGameMainMenu
@onready var load_game_panel : VBoxContainer = $LoadGameMainMenu2

@onready var btn_new_game  : Button = $MainMenu/NewGame
@onready var btn_load_game : Button = $MainMenu/LoadGame
@onready var btn_quit      : Button = $MainMenu/Quit

@onready var btn_new_slot_1 : Button = $NewGameMainMenu/NewSlot_1
@onready var btn_new_slot_2 : Button = $NewGameMainMenu/NewSlot_2
@onready var btn_new_slot_3 : Button = $NewGameMainMenu/NewSlot_3

@onready var btn_load_slot_1   : Button = $LoadGameMainMenu2/HBoxContainer/LoadSlot_1
@onready var btn_load_slot_2   : Button = $LoadGameMainMenu2/HBoxContainer2/LoadSlot_2
@onready var btn_load_slot_3   : Button = $LoadGameMainMenu2/HBoxContainer3/LoadSlot_3
@onready var btn_delete_slot_1 : Button = $LoadGameMainMenu2/HBoxContainer/DeleteSlot_1
@onready var btn_delete_slot_2 : Button = $LoadGameMainMenu2/HBoxContainer2/DeleteSlot_2
@onready var btn_delete_slot_3 : Button = $LoadGameMainMenu2/HBoxContainer3/DeleteSlot_3
const CUTSCENE_PATH = "uid://b2u7h0ht3y5y3"
const FIRST_MAP_UID = "uid://d2btqn8sfli11"

var _pending_delete_slot : int = -1

func _ready():
	AudioManager.play_music("menu")
	main_menu.scale      = Vector2.ONE
	new_game_panel.scale = Vector2.ONE
	load_game_panel.scale = Vector2.ONE

	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_load_game.pressed.connect(_on_load_game_pressed)
	btn_quit.pressed.connect(get_tree().quit)

	btn_new_slot_1.pressed.connect(func(): _start_new_game(1))
	btn_new_slot_2.pressed.connect(func(): _start_new_game(2))
	btn_new_slot_3.pressed.connect(func(): _start_new_game(3))

	btn_load_slot_1.pressed.connect(func(): _load_game(1))
	btn_load_slot_2.pressed.connect(func(): _load_game(2))
	btn_load_slot_3.pressed.connect(func(): _load_game(3))

	btn_delete_slot_1.pressed.connect(func(): _confirm_delete(1))
	btn_delete_slot_2.pressed.connect(func(): _confirm_delete(2))
	btn_delete_slot_3.pressed.connect(func(): _confirm_delete(3))

	_show_main_menu()
	_connect_button_sounds([btn_new_game, btn_load_game, btn_quit])

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if new_game_panel.visible or load_game_panel.visible:
			_show_main_menu()

func _show_main_menu():
	_pending_delete_slot    = -1
	main_menu.visible       = true
	new_game_panel.visible  = false
	load_game_panel.visible = false
	btn_load_game.disabled  = not _any_slot_exists()

func _on_new_game_pressed():
	main_menu.visible      = false
	new_game_panel.visible = true
	btn_new_slot_1.text = "Slot 1 — " + SaveManager.get_slot_info(1)
	btn_new_slot_2.text = "Slot 2 — " + SaveManager.get_slot_info(2)
	btn_new_slot_3.text = "Slot 3 — " + SaveManager.get_slot_info(3)

func _on_load_game_pressed():
	main_menu.visible       = false
	load_game_panel.visible = true
	_refresh_load_slots()

func _refresh_load_slots():
	btn_load_slot_1.text     = "Slot 1 — " + SaveManager.get_slot_info(1)
	btn_load_slot_2.text     = "Slot 2 — " + SaveManager.get_slot_info(2)
	btn_load_slot_3.text     = "Slot 3 — " + SaveManager.get_slot_info(3)
	btn_load_slot_1.disabled = not SaveManager.slot_exists(1)
	btn_load_slot_2.disabled = not SaveManager.slot_exists(2)
	btn_load_slot_3.disabled = not SaveManager.slot_exists(3)
	_update_delete_buttons()

func _confirm_delete(slot: int):
	if _pending_delete_slot == slot:
		SaveManager.delete_slot(slot)
		_pending_delete_slot = -1
		_refresh_load_slots()
		btn_load_game.disabled = not _any_slot_exists()
	else:
		_pending_delete_slot = slot
		_update_delete_buttons()

func _connect_button_sounds(buttons: Array):
	for btn in buttons:
		btn.pressed.connect(func(): AudioManager.play_sfx("button_click"))
		btn.mouse_entered.connect(func(): AudioManager.play_sfx("button_hover"))

func _update_delete_buttons():
	btn_delete_slot_1.text    = "X  Confirm?" if _pending_delete_slot == 1 else "X"
	btn_delete_slot_2.text    = "X  Confirm?" if _pending_delete_slot == 2 else "X"
	btn_delete_slot_3.text    = "X  Confirm?" if _pending_delete_slot == 3 else "X"
	btn_delete_slot_1.visible = SaveManager.slot_exists(1)
	btn_delete_slot_2.visible = SaveManager.slot_exists(2)
	btn_delete_slot_3.visible = SaveManager.slot_exists(3)

func _start_new_game(slot: int):
	SaveManager.current_slot = slot
	SaveManager.save_data["last_unlocked_level"] = 1
	SaveManager.save()
	AudioManager.stop_music() 
	get_tree().change_scene_to_file(CUTSCENE_PATH)

func _load_game(slot: int):
	SaveManager.load_slot(slot)
	var level    = SaveManager.save_data["last_unlocked_level"]
	var scene_uid = _get_scene_uid_for_level(level)
	AudioManager.stop_music() 
	SceneManager.transition_scene(scene_uid, "LevelTransition", Vector2.ZERO, "left")

func _any_slot_exists() -> bool:
	return SaveManager.slot_exists(1) or SaveManager.slot_exists(2) or SaveManager.slot_exists(3)

func _get_scene_uid_for_level(level: int) -> String:
	for uid in SaveManager.LEVEL_MAP:
		if SaveManager.LEVEL_MAP[uid] == level:
			return uid
	return FIRST_MAP_UID
