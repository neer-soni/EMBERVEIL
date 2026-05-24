extends CanvasLayer

signal load_scene_started
signal new_scene_ready(target_name: String, offset: Vector2)
signal load_scene_finished

@onready var fade: Control = $Control

func _ready() -> void:
	
	fade.visible = false
	await get_tree().process_frame
	load_scene_finished.emit()

func transition_scene(new_scene: String, target_area: String, player_offset: Vector2, dir: String) -> void:
	var fade_pos: Vector2 = get_fade_pos(dir)

	load_scene_started.emit()

	# Fade OUT: slide panel from off-screen INTO center (covering the screen)
	await fade_screen(fade_pos, Vector2.ZERO)

	call_deferred("_do_change_scene", new_scene, target_area, player_offset, dir)

func _do_change_scene(new_scene: String, target_area: String, player_offset: Vector2, dir: String) -> void:
	fade.visible = true
	fade.position = Vector2.ZERO  # Keep it covering screen during scene load

	get_tree().change_scene_to_file(new_scene)
	await get_tree().scene_changed

	new_scene_ready.emit(target_area, player_offset)

	# Fade IN: slide panel OFF-screen, revealing the new scene
	var exit_pos: Vector2 = get_fade_pos(dir) * -1  # Opposite direction
	await fade_screen(Vector2.ZERO, exit_pos)

	fade.visible = false
	load_scene_finished.emit()

func fade_screen(from: Vector2, to: Vector2) -> void:
	fade.visible = true
	fade.position = from

	var tween: Tween = create_tween()
	tween.tween_property(fade, "position", to, 0.3)

	await tween.finished  # ✅ Correctly awaits the tween completing

func get_fade_pos(dir: String) -> Vector2:
	var vp: Vector2 = Vector2(480 * 2, 270 * 2)
	match dir:
		"left":
			return Vector2(-vp.x, 0)   # Panel comes from the left
		"right":
			return Vector2(vp.x, 0)    # Panel comes from the right
		"up":
			return Vector2(0, -vp.y)   # ✅ Fixed: uses Y axis
		"down":
			return Vector2(0, vp.y)    # ✅ Fixed: uses Y axis
	return Vector2.ZERO
