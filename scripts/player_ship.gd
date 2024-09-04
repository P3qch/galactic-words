extends Node2D

@export var Bullet: PackedScene
signal got_hit


func shoot_at(ship: EnemyCore) -> void:
	look_at(ship.position)
	ship.take_damage()
	var b: Area2D = Bullet.instantiate()
	b.target = ship
	get_parent().add_child(b)
	b.transform = $Cannon.global_transform
	$CannonAudio.play()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is EnemyCore:
		got_hit.emit()
