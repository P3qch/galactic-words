class_name EnemyCore
extends Area2D

@export var speed: float
@export var word_label: Label

var last_shot_at_time: float = 0

var word: String : 
	set(x):
		word = x.to_upper().strip_escapes()
		word_label.text = word
	get:
		return word

var target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	word_label.text = word
	
func _process(delta: float) -> void:
	if Time.get_unix_time_from_system() - last_shot_at_time > 0.15:
		var angle: float = get_angle_to(target_pos)
		position += Vector2.RIGHT.rotated(angle) * speed * delta


func select() -> void:
	word_label.label_settings.font_color = Color.YELLOW

func unselect() -> void:
	word_label.label_settings.font_color = Color.WHITE


	
func take_damage() -> void:
	last_shot_at_time = Time.get_unix_time_from_system()
	word = word.substr(1, -1)
	if word == "":
		queue_free()


	
