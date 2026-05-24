extends Control
@export var health_changed_label : PackedScene 

func _ready():
	SignalBus.connect("on_health_changed", on_signal_health_changed)



func on_signal_health_changed(_node: Node, _amount_changed: int):
	var label_instance = health_changed_label.instantiate()
	var _label = label_instance.get_node
	label_instance.text = "-" + str(_amount_changed)
	label_instance.position = Vector2(0, -50)
	var tween = label_instance.create_tween()
	tween.tween_property(label_instance, "position", Vector2(0, -120), 0.8)
	tween.parallel().tween_property(label_instance, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label_instance.queue_free)
	
	
