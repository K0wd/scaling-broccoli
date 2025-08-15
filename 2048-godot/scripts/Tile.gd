extends Panel

var value = 0

func _ready():
	update_appearance()

func set_value(v):
	value = v
	update_appearance()

func update_appearance():
	var label = $Label
	if value == 0:
		label.text = ""
	else:
		label.text = str(value)
	
	# Update colors based on value
	var style = get_theme_stylebox("panel")
	var text_color = Color(0.4, 0.4, 0.4, 1.0)  # Default dark gray text
	var bg_color = Color(0.9, 0.9, 0.9, 1.0) # Default light gray for empty tiles
	
	match value:
		0:
			bg_color = Color(0.85, 0.85, 0.85, 1.0) # Light gray
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		2:
			bg_color = Color(0.98, 0.94, 0.9, 1.0) # Very light peach
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		4:
			bg_color = Color(0.98, 0.88, 0.82, 1.0) # Light salmon
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		8:
			bg_color = Color(0.95, 0.85, 0.67, 1.0) # Light orange
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		16:
			bg_color = Color(0.94, 0.69, 0.57, 1.0) # Coral
			text_color = Color.WHITE
		32:
			bg_color = Color(0.97, 0.76, 0.76, 1.0) # Light pink
			text_color = Color.WHITE
		64:
			bg_color = Color(0.95, 0.6, 0.69, 1.0) # Pink
			text_color = Color.WHITE
		128:
			bg_color = Color(0.87, 0.82, 0.95, 1.0) # Light purple
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		256:
			bg_color = Color(0.78, 0.73, 0.95, 1.0) # Purple
			text_color = Color.WHITE
		512:
			bg_color = Color(0.73, 0.88, 0.95, 1.0) # Light blue
			text_color = Color.WHITE
		1024:
			bg_color = Color(0.67, 0.85, 0.95, 1.0) # Blue
			text_color = Color.WHITE
		2048:
			bg_color = Color(0.7, 0.95, 0.7, 1.0) # Light green
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		4096:
			bg_color = Color(0.95, 0.95, 0.7, 1.0) # Light yellow
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		8192:
			bg_color = Color(0.95, 0.85, 0.95, 1.0) # Light magenta
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		16384:
			bg_color = Color(0.85, 0.95, 0.9, 1.0) # Mint
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		32768:
			bg_color = Color(0.95, 0.9, 0.8, 1.0) # Cream
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		65536:
			bg_color = Color(0.9, 0.85, 0.95, 1.0) # Lavender
			text_color = Color(0.4, 0.4, 0.4, 1.0)
		_:
			# For higher numbers, generate a soft pastel color
			var hue = fmod(value / 131072.0, 1.0)
			bg_color = Color.from_hsv(hue, 0.3, 0.95) # Low saturation, high value for pastels
			text_color = Color(0.4, 0.4, 0.4, 1.0)
	
	# Apply colors
	add_theme_color_override("panel", bg_color)
	label.add_theme_color_override("font_color", text_color)
	
	# Adjust font size based on number length
	var font_size = 36
	if value >= 100000:
		font_size = 20
	elif value >= 10000:
		font_size = 24
	elif value >= 1000:
		font_size = 28
	elif value >= 100:
		font_size = 32
	label.add_theme_font_size_override("font_size", font_size)
	
	# Add rounded corners
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = bg_color
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style_box)
