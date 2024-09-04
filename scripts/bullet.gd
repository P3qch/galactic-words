extends Area2D

@export var SPEED: float = 2000
var target: EnemyCore

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	look_at(target.position)
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area == target:
		#target.take_damage()
		queue_free()
