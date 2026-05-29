extends Node

const SETTINGS_PATH = "user://audio_settings.cfg"

var music_volume : float = 1.0
var sfx_volume   : float = 1.0
var is_muted     : bool  = false

@onready var music_player : AudioStreamPlayer = $MusicPlayer
@onready var sfx_player   : AudioStreamPlayer = $SfxPlayer

# Music tracks
const MUSIC = {
	"menu":   preload("res://audio/music/mainMenu.ogg"),
	"level1": preload("res://audio/music/First_map.ogg"),
	"level2": preload("res://audio/music/Second_map.ogg"),
	"level3": preload("res://audio/music/Third_map.ogg"),
	"final":  preload("res://audio/music/Final_map.ogg"),
	"dead":   preload("res://audio/music/dead_state.ogg"),
}

# SFX
const SFX = {
	"button_click":   preload("res://audio/sfx/button_click.ogg"),
	"button_hover":   preload("res://audio/sfx/button_hovering.ogg"),
	"player_hit":     preload("res://audio/sfx/player_hit.ogg"),
	"player_death":   preload("res://audio/sfx/player_death.ogg"),
	"sword_swing":    preload("res://audio/sfx/sword_swing.ogg"),
	"enemy_hit":      preload("res://audio/sfx/Enemy_hit.ogg"),
	"enemy_death":    preload("res://audio/sfx/Enemy_death.ogg"),
	"level_transition": preload("res://audio/sfx/level_transition.ogg"),
}

func _ready():
	load_settings()
	_apply_volumes()

func play_music(key: String, fade: bool = true):
	if not MUSIC.has(key):
		return
	var stream = MUSIC[key]
	if music_player.stream == stream and music_player.playing:
		return  # already playing
	if fade and music_player.playing:
		await _fade_out(music_player)
	music_player.stream = stream
	music_player.play()
	if fade:
		_fade_in(music_player)

func stop_music(fade: bool = true):
	if fade:
		await _fade_out(music_player)
	music_player.stop()

func play_sfx(key: String):
	if not SFX.has(key):
		return
	sfx_player.stream = SFX[key]
	sfx_player.play()

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	_apply_volumes()
	save_settings()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	_apply_volumes()
	save_settings()

func set_mute(value: bool):
	is_muted = value
	_apply_volumes()
	save_settings()

func _apply_volumes():
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus   = AudioServer.get_bus_index("SFX")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume) if not is_muted else -80.0)
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume) if not is_muted else -80.0)

func _fade_out(player: AudioStreamPlayer, duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished

func _fade_in(player: AudioStreamPlayer, duration: float = 0.5):
	player.volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(player, "volume_db", linear_to_db(music_volume), duration)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume",   sfx_volume)
	config.set_value("audio", "is_muted",     is_muted)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume   = config.get_value("audio", "sfx_volume",   1.0)
	is_muted     = config.get_value("audio", "is_muted",     false)
