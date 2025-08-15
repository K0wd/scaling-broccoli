extends Node

signal leaderboard_updated
signal high_score_achieved(score: int, rank: int)

const LEADERBOARD_SIZE = 10
const SAVE_FILE = "user://leaderboards.save"

# Game modes (matching GameManager)
enum GameMode { CLASSIC, BLITZ, ARCADE }

var leaderboards = {
	GameMode.CLASSIC: [],
	GameMode.BLITZ: [],
	GameMode.ARCADE: []
}

var player_name = ""
var last_submitted_score = 0

func _ready() -> void:
	load_leaderboards()

func submit_score(score: int, mode: int) -> void:
	last_submitted_score = score
	
	# Get current leaderboard
	var board = leaderboards[mode]
	
	# Check if score qualifies for leaderboard
	var position = -1
	for i in range(board.size()):
		if score > board[i].score:
			position = i
			break
	
	# If score doesn't qualify and board is full, return
	if position == -1 and board.size() >= LEADERBOARD_SIZE:
		return
	
	# If board isn't full, add score at the end
	if position == -1:
		position = board.size()
	
	# Create score entry
	var entry = {
		"name": player_name if player_name != "" else "Player",
		"score": score,
		"date": Time.get_datetime_string_from_system(),
		"mode": mode,
		"grid_size": get_node("/root/GameManager").SIZE
	}
	
	# Insert score at correct position
	board.insert(position, entry)
	
	# Trim leaderboard if necessary
	if board.size() > LEADERBOARD_SIZE:
		board.resize(LEADERBOARD_SIZE)
	
	# Save leaderboards
	save_leaderboards()
	
	# Emit signals
	emit_signal("leaderboard_updated")
	emit_signal("high_score_achieved", score, position + 1)

func get_leaderboard(mode: int) -> Array:
	return leaderboards[mode]

func get_player_rank(score: int, mode: int) -> int:
	var board = leaderboards[mode]
	for i in range(board.size()):
		if score > board[i].score:
			return i + 1
	return board.size() + 1

func set_player_name(name: String) -> void:
	player_name = name
	# Update last submitted score's name if it exists
	for mode in leaderboards:
		var board = leaderboards[mode]
		for entry in board:
			if entry.score == last_submitted_score:
				entry.name = name
				save_leaderboards()
				emit_signal("leaderboard_updated")
				break

func save_leaderboards() -> void:
	var save_data = {
		"leaderboards": leaderboards,
		"version": 1  # For future compatibility
	}
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()

func load_leaderboards() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var save_file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var save_data = save_file.get_var()
		save_file.close()
		
		if save_data is Dictionary and save_data.has("leaderboards"):
			leaderboards = save_data.leaderboards
	
	# Initialize empty leaderboards if needed
	for mode in GameMode.values():
		if not leaderboards.has(mode):
			leaderboards[mode] = []

func format_score(score: int) -> String:
	if score >= 1000000:
		return str(score / 1000000) + "M"
	elif score >= 1000:
		return str(score / 1000) + "K"
	return str(score)

func get_top_score(mode: int) -> int:
	var board = leaderboards[mode]
	if board.size() > 0:
		return board[0].score
	return 0

func clear_leaderboards() -> void:
	for mode in leaderboards:
		leaderboards[mode].clear()
	save_leaderboards()
	emit_signal("leaderboard_updated") 