extends Node2D

signal start_game

var _wpm_entries: int = 0
var _wpm_sum: float = 0

var wpm: float : # the avarage wpm
	set(x):
		_wpm_sum += x
		_wpm_entries += 1
		wpm = _wpm_sum / _wpm_entries
		$WpmLabel.text = "%.02f" % wpm
	get:
		return wpm

var score: int = 0 : 
	set(x):
		score = x
		$ScoreLabel.text = str(x)
	get:
		return score

func _ready() -> void:
	$LevelLabel.modulate.a = 0

func _on_start_button_pressed() -> void:
	$ControlHud.hide()
	start_game.emit()
	score = 0
	
func game_over_screen() -> void:
	$ControlHud.show()
	$ControlHud/TitleLabel.text = "GAME OVER!"
	$LevelLabel.modulate.a = 1

func set_accuracy(mistakes: int) -> void:
	$AccLabel.text = "%.02f" % ((score as float / (score + mistakes)) * 100)
	
func show_level(level: int) -> void:
	$LevelLabel.modulate.a = 1
	$LevelLabel.text = "LEVEL " + str(level)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($LevelLabel, "modulate:a", 0.0, 2.0)

	
