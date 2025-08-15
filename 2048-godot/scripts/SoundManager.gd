extends Node

# Sound effect types
enum SoundType {MOVE, MERGE, POWERUP, UI, ACHIEVEMENT, AMBIENT}

# Sound properties
var master_volume := 1.0
var sound_enabled := true
var music_enabled := true
var asmr_enabled := true

# Audio players
var audio_players := {}
var ambient_players := {}
var music_player: AudioStreamPlayer

# Sound variations for ASMR
var move_variations := []
var merge_variations := []
var current_combo := 0
var max_combo := 0

func _ready() -> void:
	# Initialize audio players
	for type in SoundType.values():
		var player = AudioStreamPlayer.new()
		add_child(player)
		audio_players[type] = player
	
	# Initialize ambient sounds
	var ambient_types = ["soft_wind", "chimes", "rain"]
	for type in ambient_types:
		var player = AudioStreamPlayer.new()
		add_child(player)
		ambient_players[type] = player
	
	# Initialize music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Load sound variations
	load_sound_variations()
	
	# Connect to game signals
	GameManager.connect("game_mode_changed", _on_game_mode_changed)
	GameManager.connect("score_updated", _on_score_updated)
	GameManager.connect("achievement_unlocked", _on_achievement_unlocked)

func load_sound_variations() -> void:
	# Load different variations of move sounds
	var move_files = ["slide", "soft_tap", "gentle_move"]
	for file in move_files:
		var stream = ResourceLoader.exists("res://assets/sounds/" + file + ".ogg")
		if stream:
			var audio = load("res://assets/sounds/" + file + ".ogg")
			if audio:
				move_variations.append(audio)
	
	# Load different variations of merge sounds
	var merge_files = ["merge", "pop", "chime"]
	for file in merge_files:
		var stream = ResourceLoader.exists("res://assets/sounds/" + file + ".ogg")
		if stream:
			var audio = load("res://assets/sounds/" + file + ".ogg")
			if audio:
				merge_variations.append(audio)

func play_move_sound(direction: Vector2) -> void:
	if not sound_enabled or move_variations.is_empty():
		return
	
	var player = audio_players[SoundType.MOVE]
	# Select variation based on direction and current combo
	var index = wrapi(current_combo + int(direction.x) + int(direction.y), 0, move_variations.size())
	player.stream = move_variations[index]
	
	# Adjust pitch and volume for ASMR effect
	if asmr_enabled:
		player.pitch_scale = randf_range(0.95, 1.05)
		player.volume_db = linear_to_db(0.8 + current_combo * 0.05)
	
	player.play()

func play_merge_sound(value: int, combo: int) -> void:
	if not sound_enabled or merge_variations.is_empty():
		return
	
	var player = audio_players[SoundType.MERGE]
	# Select variation based on tile value and combo
	var log_value = int(log(float(value)) / log(2.0))
	var index = wrapi(combo + log_value, 0, merge_variations.size())
	player.stream = merge_variations[index]
	
	# Adjust pitch and volume based on value and combo
	if asmr_enabled:
		var pitch_scale = 1.0 + log(float(value)) / log(2048.0) * 0.2
		player.pitch_scale = clamp(pitch_scale, 0.8, 1.5)
		player.volume_db = linear_to_db(0.7 + combo * 0.1)
	
	player.play()
	
	current_combo = combo
	max_combo = max(max_combo, combo)

func play_powerup_sound(powerup_type: String) -> void:
	if not sound_enabled:
		return
	
	var player = audio_players[SoundType.POWERUP]
	var path = "res://assets/sounds/powerup_" + powerup_type + ".ogg"
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream:
			player.stream = stream
			player.play()

func play_achievement_sound() -> void:
	if not sound_enabled:
		return
	
	var player = audio_players[SoundType.ACHIEVEMENT]
	var path = "res://assets/sounds/achievement.ogg"
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream:
			player.stream = stream
			player.play()

func update_ambient_sounds(_delta: float) -> void:
	if not asmr_enabled:
		return
	
	# Update ambient sound mix based on game state and score
	for type in ambient_players:
		var player = ambient_players[type]
		match type:
			"soft_wind":
				player.volume_db = linear_to_db(0.3 + current_combo * 0.05)
			"chimes":
				player.volume_db = linear_to_db(0.2 + max_combo * 0.02)
			"rain":
				player.volume_db = linear_to_db(0.1)
			_:
				pass

func _on_game_mode_changed(mode):
	# Adjust sound mix based on game mode
	match mode:
		GameManager.GameMode.BLITZ:
			set_asmr_intensity(0.7)
		GameManager.GameMode.ARCADE:
			set_asmr_intensity(1.0)
		_:
			set_asmr_intensity(0.5)

func _on_score_updated(_score, multiplier):
	# Adjust sound intensity based on score multiplier
	if asmr_enabled:
		set_asmr_intensity(0.5 + multiplier * 0.1)

func _on_achievement_unlocked(_achievement):
	play_achievement_sound()

func set_asmr_intensity(intensity: float) -> void:
	if not asmr_enabled:
		return
	
	intensity = clamp(intensity, 0.0, 1.0)
	for player in audio_players.values():
		player.volume_db = linear_to_db(0.8 * intensity)
	
	for player in ambient_players.values():
		player.volume_db = linear_to_db(0.3 * intensity)

func toggle_sound(enabled: bool) -> void:
	sound_enabled = enabled
	for player in audio_players.values():
		player.volume_db = -80 if not enabled else 0

func toggle_music(enabled: bool) -> void:
	music_enabled = enabled
	music_player.volume_db = -80 if not enabled else 0

func toggle_asmr(enabled: bool) -> void:
	asmr_enabled = enabled
	if enabled:
		set_asmr_intensity(0.5)
	else:
		for player in ambient_players.values():
			player.stop() 