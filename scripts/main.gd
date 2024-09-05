extends Node

@export var SmallEnemy: PackedScene
var selection_time: float
var selected_ship_word_len: float

var words: Array
var small_words: Array
var medium_words: Array
var big_words: Array

var mistakes_made: int = 0

const MAX_SMALL_WORD_LEN: int = 7
const MIN_BIG_WORD_LEN: int = 13


var selected_ship: EnemyCore :
	set(x):
		selected_ship = x
		if x:
			selection_time = Time.get_unix_time_from_system()
			selected_ship_word_len = x.word.length()
		else:
			selection_time = 0
			selected_ship_word_len = 0
	get:
		return selected_ship
		


func prepare_word_arrays(filename: String) -> void:
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
	words = file.get_as_text().split("\n")
	words = words.map(func(x: String) -> String: return x.strip_edges())
	file.close()
	
	small_words = words.filter(func(x: String) -> bool: return x.length() <= MAX_SMALL_WORD_LEN)
	medium_words = words.filter(func(x: String) -> bool: return x.length() > MAX_SMALL_WORD_LEN and  x.length() < MIN_BIG_WORD_LEN )
	big_words = words.filter(func(x: String) -> bool: return x.length() >= MIN_BIG_WORD_LEN )


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepare_word_arrays("res://words.txt")

func get_ships() -> Array:
	var result: Array
	
	for child: Node in get_children():
		if child is EnemyCore:
			result.append(child)
	
	return result

func find_ship_by_letter(c: String) -> EnemyCore:
	var ships: Array = get_ships()
	for ship: EnemyCore in ships:
		if ship.word.begins_with(c):	
			return ship
			
	return null

func find_wpm(char_amount: float, time_taken: float) -> float:
	return (char_amount/5) / time_taken

func handle_keypress(c: String) -> void:
	if selected_ship == null:
		selected_ship = find_ship_by_letter(c)
		
		if selected_ship == null:
			mistakes_made += 1	
			return	
			
		selected_ship.select()


	if selected_ship.word.begins_with(c):
		$PlayerShip.shoot_at(selected_ship)	
		$HUD.score += 1 
	else:
		mistakes_made += 1		
	
	if selected_ship.is_queued_for_deletion():
		var time_taken: float = (Time.get_unix_time_from_system() - selection_time)/60
		$HUD.wpm = find_wpm(selected_ship_word_len, time_taken)
		
		selected_ship = null
	
	$HUD.set_accuracy(mistakes_made)	
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			handle_keypress(event.as_text_key_label())
			
			if event.keycode == KEY_F11:
				if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
				elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
		

func get_random_word() -> String:
	var random: float = randf()
	var result: String
	if random < 0.7:
		result = small_words.pick_random()
	elif random >= 0.7 and random < 0.95:
		result = medium_words.pick_random()
	else:
		result = big_words.pick_random()
	return result

func _on_ship_spawn_timer_timeout() -> void:
	$Path2D/PathFollow2D.progress_ratio = randf()
	var enemy: EnemyCore = SmallEnemy.instantiate()
	enemy.position = $Path2D/PathFollow2D.position
	enemy.target_pos = $PlayerShip.position
	enemy.word = get_random_word()


	add_child(enemy)


func _on_player_ship_got_hit() -> void:
	$ShipSpawnTimer.stop()
	$HUD.game_over_screen()
	get_ships().map(func(x: EnemyCore) -> void: x.queue_free())

func _on_hud_start_game() -> void:
	$ShipSpawnTimer.start()
