extends Node

enum GameMode { CLASSIC, BLITZ, ARCADE }
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

signal game_mode_changed(mode: int)
signal game_state_changed(state: int)
signal score_updated(score: int, multiplier: float)
signal achievement_unlocked(achievement_name: String)

var current_mode: int = GameMode.CLASSIC
var current_state: int = GameState.MENU
var current_score := 0
var score_multiplier := 1.0
var combo_count := 0
var time_remaining := 0.0
var SIZE := 4

# Blitz mode settings
const BLITZ_TIME := 180.0 # 3 minutes
const BLITZ_BONUS_TIME := 5.0 # Seconds added per merge

# Arcade mode settings
const POWERUP_DURATION := 10.0
const MAX_POWERUPS := 3

# Achievement data
var achievements := {}
var powerups := {}

func _ready() -> void:
	load_achievements()
	reset_powerups()

func start_game(mode: int) -> void:
	current_mode = mode
	current_state = GameState.PLAYING
	current_score = 0
	score_multiplier = 1.0
	combo_count = 0
	
	match mode:
		GameMode.BLITZ:
			time_remaining = BLITZ_TIME
		GameMode.ARCADE:
			reset_powerups()
		_:
			pass
	
	emit_signal("game_mode_changed", mode)
	emit_signal("game_state_changed", GameState.PLAYING)

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		emit_signal("game_state_changed", GameState.PAUSED)

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		emit_signal("game_state_changed", GameState.PLAYING)

func game_over() -> void:
	current_state = GameState.GAME_OVER
	emit_signal("game_state_changed", GameState.GAME_OVER)

func add_score(value: int, merge_level: int = 1) -> void:
	var bonus_multiplier = 1.0
	
	# Combo system
	if merge_level > 1:
		combo_count += 1
		bonus_multiplier += combo_count * 0.1
	else:
		combo_count = 0
	
	# Mode-specific bonuses
	match current_mode:
		GameMode.BLITZ:
			time_remaining += BLITZ_BONUS_TIME
			bonus_multiplier += (1.0 - time_remaining / BLITZ_TIME) * 0.5
		GameMode.ARCADE:
			bonus_multiplier += powerups.get("score_boost", 0.0)
		_:
			pass
	
	var final_score = value * score_multiplier * bonus_multiplier
	current_score += int(final_score)
	emit_signal("score_updated", current_score, score_multiplier * bonus_multiplier)
	check_achievements(current_score, merge_level)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING and current_mode == GameMode.BLITZ:
		time_remaining -= delta
		if time_remaining <= 0:
			game_over()

# Achievement system
func load_achievements() -> void:
	achievements = {
		"rookie": {"name": "Rookie", "description": "Reach 2048", "score": 2048, "unlocked": false},
		"expert": {"name": "Expert", "description": "Reach 4096", "score": 4096, "unlocked": false},
		"master": {"name": "Master", "description": "Reach 8192", "score": 8192, "unlocked": false},
		"legend": {"name": "Legend", "description": "Reach 16384", "score": 16384, "unlocked": false},
		"beyond": {"name": "Beyond", "description": "Reach 32768", "score": 32768, "unlocked": false},
		"combo_master": {"name": "Combo Master", "description": "Get a 5x combo", "combo": 5, "unlocked": false}
	}

func check_achievements(score: int, combo: int) -> void:
	for id in achievements:
		var achievement = achievements[id]
		if not achievement.unlocked:
			if achievement.has("score") and score >= achievement.score:
				unlock_achievement(id)
			elif achievement.has("combo") and combo >= achievement.combo:
				unlock_achievement(id)

func unlock_achievement(id: String) -> void:
	if achievements.has(id) and not achievements[id].unlocked:
		achievements[id].unlocked = true
		emit_signal("achievement_unlocked", achievements[id].name)

# Power-up system for Arcade mode
func reset_powerups() -> void:
	powerups = {
		"score_boost": 0.0,
		"time_slow": 0.0,
		"mega_merge": 0.0
	}

func activate_powerup(type: String) -> void:
	if powerups.has(type) and powerups[type] <= 0:
		powerups[type] = POWERUP_DURATION
		match type:
			"score_boost":
				score_multiplier *= 2.0
			"time_slow":
				Engine.time_scale = 0.5
			"mega_merge":
				pass # Handled in game logic
			_:
				pass

func update_powerups(delta: float) -> void:
	if current_mode != GameMode.ARCADE:
		return
		
	for type in powerups:
		if powerups[type] > 0:
			powerups[type] -= delta
			if powerups[type] <= 0:
				deactivate_powerup(type)

func deactivate_powerup(type: String) -> void:
	match type:
		"score_boost":
			score_multiplier = max(1.0, score_multiplier / 2.0)
		"time_slow":
			Engine.time_scale = 1.0
		_:
			pass 