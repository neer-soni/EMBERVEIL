extends CanvasLayer

@onready var hp_bar          : TextureProgressBar = %HpBar
@onready var game_over_panel : Control            = $Control2
@onready var btn_menu        : Button             = $Control2/HBoxContainer/Menu
@onready var btn_quit        : Button             = $Control2/HBoxContainer/Quit

func _ready():
	game_over_panel.visible = false
	btn_menu.pressed.connect(_on_menu_pressed)
	btn_quit.pressed.connect(get_tree().quit)
	_connect_button_sounds([btn_menu, btn_quit,])

func update_health_bar(hp: float, max_hp: float) -> void:
	hp_bar.max_value = 100.0
	hp_bar.value     = (hp / max_hp) * 100.0

func show_game_over():
	AudioManager.stop_music(false)
	AudioManager.play_music("dead", false)
	game_over_panel.visible = true


func _connect_button_sounds(buttons: Array):
	for btn in buttons:
		btn.pressed.connect(func(): AudioManager.play_sfx("button_click"))
		btn.mouse_entered.connect(func(): AudioManager.play_sfx("button_hover"))



func _on_menu_pressed():
	game_over_panel.visible = false
	SceneManager.transition_scene(
		"uid://cb6gbe8qaands",
		"LevelTransition",
		Vector2.ZERO,
        "left"
	)
