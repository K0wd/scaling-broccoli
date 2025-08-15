extends Control

@onready var mode_option = $VBoxContainer/ModeOptionButton
@onready var score_list = $VBoxContainer/ScrollContainer/ScoreList
@onready var back_button = $VBoxContainer/BackButton

func _ready() -> void:
	# Initialize mode options
	mode_option.clear()
	mode_option.add_item("Classic Mode", ScoreManager.GameMode.CLASSIC)
	mode_option.add_item("Blitz Mode", ScoreManager.GameMode.BLITZ)
	mode_option.add_item("Arcade Mode", ScoreManager.GameMode.ARCADE)
	
	# Connect signals
	mode_option.item_selected.connect(_on_mode_selected)
	back_button.pressed.connect(_on_back_pressed)
	
	# Load initial scores
	update_scores(ScoreManager.GameMode.CLASSIC)

func update_scores(mode: int) -> void:
	# Clear existing scores
	for child in score_list.get_children():
		child.queue_free()
	
	# Get scores for selected mode
	var scores = ScoreManager.get_leaderboard(mode)
	
	# Create score entries
	for i in range(scores.size()):
		var score = scores[i]
		var entry = create_score_entry(i + 1, score)
		score_list.add_child(entry)

func create_score_entry(rank: int, score: Dictionary) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var rank_label = Label.new()
	rank_label.text = "#" + str(rank)
	rank_label.custom_minimum_size = Vector2(50, 0)
	
	var name_label = Label.new()
	name_label.text = score.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var score_label = Label.new()
	score_label.text = ScoreManager.format_score(score.score)
	score_label.custom_minimum_size = Vector2(100, 0)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	var date_label = Label.new()
	date_label.text = score.date.split(" ")[0] # Show only the date part
	date_label.custom_minimum_size = Vector2(100, 0)
	
	var grid_label = Label.new()
	grid_label.text = str(score.grid_size) + "x" + str(score.grid_size)
	grid_label.custom_minimum_size = Vector2(50, 0)
	grid_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	container.add_child(rank_label)
	container.add_child(name_label)
	container.add_child(score_label)
	container.add_child(date_label)
	container.add_child(grid_label)
	
	return container

func _on_mode_selected(index: int) -> void:
	var mode = mode_option.get_item_id(index)
	update_scores(mode)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 