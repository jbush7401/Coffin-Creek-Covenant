extends Control

var card_being_dragged = null
var card_drag_offset: Vector2 = Vector2.ZERO

# Hand configuration
var hand_size: int = 6
var card_spacing: float = 120.0
var hand_y_offset: float = -50.0  # Distance from bottom of screen

# Preload the card scene
var Card = preload("res://Scenes/Card/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	initialize_hand()


func initialize_hand() -> void:
	# Get viewport size once
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate hand positioning
	var total_width = card_spacing * (hand_size - 1)
	var start_x = (viewport_size.x - total_width) / 2
	# Initialize the hand with a set number of cards
	for i in range(hand_size):
		# Create a new card instance
		var card = Card.instantiate()
		card.mouse_filter = MOUSE_FILTER_PASS
		# Calculate position after card is in scene
		var card_x = start_x + i * card_spacing
		var hand_y = viewport_size.y - card.get_size().y - hand_y_offset

		var hand_pos = Vector2(card_x, hand_y)
		
		# Set the position of the card
		card.position = hand_pos
		card.hand_position = hand_pos

		add_child(card)
		
		# Give each card a unique name for debugging
		card.name = "Card_" + str(i)

		print("Card ", i, " positioned at: ", card.position)

# Handle all input events on the CardManager
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Find which card (if any) is under the mouse
				var clicked_card = get_card_under_mouse(mouse_event.global_position)
				if clicked_card and card_being_dragged == null:
					print("Mouse pressed on: ", clicked_card.name)
					start_drag(clicked_card, mouse_event.global_position)
			else:
				# Stop dragging
				if card_being_dragged:
					print("Mouse released")
					stop_drag()
	
	elif event is InputEventMouseMotion and card_being_dragged:
		# Continue dragging
		update_drag(event.global_position)

# Find which card is under the mouse position
func get_card_under_mouse(global_pos: Vector2) -> Control:
	# Check cards from back to front (reverse order)
	var cards = get_children()
	cards.reverse()
	
	for card in cards:
		# Check if the mouse is within this card's bounds
		var card_rect = Rect2(card.global_position, card.get_size())
		if card_rect.has_point(global_pos):
			return card
	
	return null

# Start dragging a card
func start_drag(card: Control, mouse_pos: Vector2) -> void:
	print("Starting drag on: ", card.name)
	card_being_dragged = card
	card_drag_offset = mouse_pos - card.global_position
	print("Started dragging card at: ", card.position)

# Update card position during drag
func update_drag(mouse_pos: Vector2) -> void:
	if card_being_dragged:
		var new_pos = mouse_pos - card_drag_offset
		card_being_dragged.global_position = new_pos

# Stop dragging
func stop_drag() -> void:
	if card_being_dragged:
		print("Stopped dragging: ", card_being_dragged.name, " at: ", card_being_dragged.position)
		card_being_dragged.return_to_hand()
		card_being_dragged = null
		card_drag_offset = Vector2.ZERO

