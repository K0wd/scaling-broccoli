extends Control

@onready var player_name_input = $VBoxContainer/PlayerNameInput
@onready var grid_size_option = $VBoxContainer/GridSizeOption
@onready var sound_toggle = $VBoxContainer/OptionsContainer/SoundToggle
@onready var music_toggle = $VBoxContainer/OptionsContainer/MusicToggle
@onready var asmr_toggle = $VBoxContainer/OptionsContainer/ASMRToggle
@onready var classic_button = $VBoxContainer/ModesContainer/ClassicButton
@onready var blitz_button = $VBoxContainer/ModesContainer/BlitzButton
@onready var arcade_button = $VBoxContainer/ModesContainer/ArcadeButton
@onready var leaderboard_button = $VBoxContainer/LeaderboardButton

func _ready() -> void:
	# Initialize grid size options
	grid_size_option.clear()
	for size in range(3, 6):  # Only 3x3, 4x4, 5x5
		grid_size_option.add_item(str(size) + "x" + str(size))
	grid_size_option.select(1) # Default to 4x4
	
	# Initialize toggles
	sound_toggle.button_pressed = SoundManager.sound_enabled
	music_toggle.button_pressed = SoundManager.music_enabled
	asmr_toggle.button_pressed = SoundManager.asmr_enabled
	
	# Set initial player name
	if ScoreManager.player_name != "":
		player_name_input.text = ScoreManager.player_name
	
	# Connect signals
	player_name_input.text_changed.connect(_on_player_name_changed)
	classic_button.pressed.connect(_on_classic_pressed)
	blitz_button.pressed.connect(_on_blitz_pressed)
	arcade_button.pressed.connect(_on_arcade_pressed)
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	sound_toggle.toggled.connect(_on_sound_toggled)
	music_toggle.toggled.connect(_on_music_toggled)
	asmr_toggle.toggled.connect(_on_asmr_toggled)

func _on_classic_pressed() -> void:
	_start_game(GameManager.GameMode.CLASSIC)

func _on_blitz_pressed() -> void:
	_start_game(GameManager.GameMode.BLITZ)

func _on_arcade_pressed() -> void:
	_start_game(GameManager.GameMode.ARCADE)

func _start_game(mode: int) -> void:
	GameManager.SIZE = grid_size_option.selected + 3  # 3x3 = 0+3, 4x4 = 1+3, 5x5 = 2+3
	get_tree().change_scene_to_file("res://scenes/Game2048.tscn")
	GameManager.start_game(mode)

func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")

func _on_sound_toggled(enabled: bool) -> void:
	SoundManager.toggle_sound(enabled)

func _on_music_toggled(enabled: bool) -> void:
	SoundManager.toggle_music(enabled)

func _on_asmr_toggled(enabled: bool) -> void:
	SoundManager.toggle_asmr(enabled)

func _on_player_name_changed(new_text: String) -> void:
	ScoreManager.set_player_name(new_text) 