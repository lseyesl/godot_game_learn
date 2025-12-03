@tool
extends Control

var duration := 2.0
var tween: Tween

func show_toast(text: String, time := 2.0):
	print('text', text)
	$Label.text = text
	
	# Ensure it's on top and doesn't block clicks
	z_index = 99
	mouse_filter = MOUSE_FILTER_IGNORE
	
	# Reset state
	show()
	modulate.a = 1.0
	
	# Center on screen
	# We need to wait for the label to resize to get accurate size if needed, 
	# but for now centering the control itself (which should be full rect or similar) is good.
	# Actually, let's just center the label or the control relative to the viewport.
	# Since this is added to base_control, we can use get_viewport_rect().
	
	var viewport_size = get_viewport_rect().size
	# Assuming the Label is the main content and the Control might be 0x0 or full screen.
	# Let's center the Label within the Control, and position the Control centrally?
	# Or simpler: Just position the Control at center.
	
	# Reset size to min size to ensure it's not huge from previous shows
	size = Vector2.ZERO
	
	# Force update to get correct size
	queue_redraw()
	
	# Center logic:
	# global_position = (viewport_size - size) / 2
	# However, size might not be updated yet. 
	# A safer bet for immediate visibility is just setting it to a known visible area like center-top.
	
	global_position = viewport_size / 2.0 - size / 2.0

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, time).set_delay(2.0)
	tween.finished.connect(hide)
