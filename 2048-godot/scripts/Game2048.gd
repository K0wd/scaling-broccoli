extends Control

var board = []
var score = 0
var best_score = 0

@onready var score_label = $MarginContainer/VBoxContainer/TopContainer/ScoreContainer/VBoxContainer/Score
@onready var best_label = $MarginContainer/VBoxContainer/TopContainer/BestContainer/VBoxContainer/Best
@onready var grid = $MarginContainer/VBoxContainer/GridBackground/Grid
@onready var grid_bg = $MarginContainer/VBoxContainer/GridBackground
@onready var menu_button = $MarginContainer/VBoxContainer/ButtonsContainer/MenuButton
@onready var leaderboard_button = $MarginContainer/VBoxContainer/ButtonsContainer/LeaderboardButton
@onready var merge_sound = $MergeSound
@onready var move_sound = $MoveSound
@onready var up_sound = $UpSound
@onready var down_sound = $DownSound
@onready var left_sound = $LeftSound
@onready var right_sound = $RightSound

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	
	# Initialize grid size based on GameManager's SIZE
	var size = GameManager.SIZE
	grid.columns = size
	
	# Calculate grid size to fit screen
	var margin = 40  # Total margin (left + right)
	var spacing = 10  # Space between tiles
	var available_width = get_viewport_rect().size.x - margin
	var available_height = get_viewport_rect().size.y - 180  # Account for top and bottom UI
	var tile_size = min(
		(available_width - (size - 1) * spacing) / size,
		(available_height - (size - 1) * spacing) / size
	)
	
	# Update grid background size
	var grid_size = tile_size * size + spacing * (size - 1)
	grid_bg.custom_minimum_size = Vector2(grid_size, grid_size)
	
	init_board()
	update_ui()

func init_board() -> void:
	board.clear()
	score = 0
	best_score = 0
	for i in GameManager.SIZE:
		var row = []
		for j in GameManager.SIZE:
			row.append(0)
		board.append(row)
	add_random_tile()
	add_random_tile()

func add_random_tile() -> void:
	var empty = []
	for y in GameManager.SIZE:
		for x in GameManager.SIZE:
			if board[y][x] == 0:
				empty.append(Vector2i(x, y))
	if empty.size() > 0:
		var pos = empty[randi() % empty.size()]
		board[pos.y][pos.x] = 2 if randf() < 0.9 else 4
		update_max_value(board[pos.y][pos.x])

func update_ui(merge_positions := []) -> void:
	# Remove old tiles
	for c in grid.get_children():
		c.queue_free()
	
	# Load the Tile scene
	var tile_scene = preload("res://scenes/Tile.tscn")
	
	# Add new tiles
	for y in GameManager.SIZE:
		for x in GameManager.SIZE:
			var val = board[y][x]
			var tile = tile_scene.instantiate()
			tile.set_value(val)
			grid.add_child(tile)
			
			# Simple scale animation for merged tiles
			for pos in merge_positions:
				if pos.x == x and pos.y == y:
					var tween = create_tween()
					tween.tween_property(tile, "scale", Vector2(1.05, 1.05), 0.05)
					tween.tween_property(tile, "scale", Vector2(1, 1), 0.05)
	
	# Update score and best score
	score_label.text = str(score)
	if score > best_score:
		best_score = score
	best_label.text = str(best_score)

func update_max_value(value: int) -> void:
	GameManager.add_score(value, 0)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var moved = false
		var merge_positions = []
		match event.keycode:
			KEY_UP:
				moved = move(Vector2i(0, -1), merge_positions)
				if moved and up_sound:
					up_sound.play()
			KEY_DOWN:
				moved = move(Vector2i(0, 1), merge_positions)
				if moved and down_sound:
					down_sound.play()
			KEY_LEFT:
				moved = move(Vector2i(-1, 0), merge_positions)
				if moved and left_sound:
					left_sound.play()
			KEY_RIGHT:
				moved = move(Vector2i(1, 0), merge_positions)
				if moved and right_sound:
					right_sound.play()
		if moved:
			add_random_tile()
			update_ui(merge_positions)

func move(dir: Vector2i, merge_positions := []) -> bool:
	var moved = false
	var merged = []
	
	# Initialize merged array with correct size
	for i in GameManager.SIZE:
		var row = []
		for j in GameManager.SIZE:
			row.append(false)
		merged.append(row)
	
	var range_y = range(GameManager.SIZE)
	var range_x = range(GameManager.SIZE)
	if dir.x > 0:
		range_x = range(GameManager.SIZE - 1, -1, -1)
	if dir.y > 0:
		range_y = range(GameManager.SIZE - 1, -1, -1)
	
	var merged_this_move = false
	var moved_this_turn = true
	while moved_this_turn:
		moved_this_turn = false
		for y in range_y:
			for x in range_x:
				var nx = x + dir.x
				var ny = y + dir.y
				if nx < 0 or nx >= GameManager.SIZE or ny < 0 or ny >= GameManager.SIZE:
					continue
				if board[y][x] == 0:
					continue
				if board[ny][nx] == 0:
					board[ny][nx] = board[y][x]
					board[y][x] = 0
					moved = true
					moved_this_turn = true
				elif board[ny][nx] == board[y][x] and not merged[ny][nx] and not merged[y][x]:
					board[ny][nx] *= 2
					score += board[ny][nx]
					board[y][x] = 0
					merged[ny][nx] = true
					merge_positions.append(Vector2i(nx, ny))
					moved = true
					merged_this_move = true
					update_max_value(board[ny][nx])
	
	if merged_this_move and merge_sound:
		merge_sound.play()
	if moved and move_sound:
		move_sound.play()
	
	return moved
