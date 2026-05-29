extends CanvasLayer

@onready var pause_panel  : ColorRect = $ColorRect
@onready var music_slider : HSlider   = $ColorRect/VBoxContainer/MusicVolume
@onready var sfx_slider   : HSlider   = $ColorRect/VBoxContainer/SfxVolume
@onready var btn_resume   : Button    = $ColorRect/VBoxContainer/Resume
@onready var btn_mute     : Button    = $ColorRect/VBoxContainer/Mute
@onready var btn_main_menu: Button    = $ColorRect/VBoxContainer/MainMenu
@onready var btn_quit     : Button    = $ColorRect/VBoxContainer/Quit

var _paused : bool = false

func _ready():
	
	pause_panel.visible = false
	btn_resume.pressed.connect(_on_resume)
	btn_mute.pressed.connect(_on_mute)
	btn_main_menu.pressed.connect(_on_main_menu)
	btn_quit.pressed.connect(get_tree().quit)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	_connect_button_sounds([btn_resume, btn_mute, btn_main_menu, btn_quit])

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if PlayerHud.game_over_panel.visible:
			return
		if _paused:
			_on_resume()
		else:
			_open_pause()

func _open_pause():
	_paused = true
	pause_panel.visible = true
	get_tree().paused   = true
	music_slider.value  = AudioManager.music_volume
	sfx_slider.value    = AudioManager.sfx_volume
	_update_mute_button()

func _on_resume():
	_paused = false
	pause_panel.visible = false
	get_tree().paused   = false

func _on_music_changed(value: float):
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float):
	AudioManager.set_sfx_volume(value)
func _on_mute():
	AudioManager.set_mute(not AudioManager.is_muted)
	_update_mute_button()

func _update_mute_button():
	btn_mute.text = "Unmute" if AudioManager.is_muted else "Mute"

func _on_main_menu():
	_paused = false
	get_tree().paused   = false
	pause_panel.visible = false
	SceneManager.transition_scene(
		"uid://cb6gbe8qaands",
		"LevelTransition",
		Vector2.ZERO,
        "left"
	)

func _connect_button_sounds(buttons: Array):
	for btn in buttons:
		btn.pressed.connect(func(): AudioManager.play_sfx("button_click"))
		btn.mouse_entered.connect(func(): AudioManager.play_sfx("button_hover"))

# Call in _ready():
