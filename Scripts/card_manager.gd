extends Control

var card_being_dragged = null
var card_drag_offset: Vector2 = Vector2.ZERO

var hand_size:int = 5
var card_spacing:float = 120.0

var Card = preload("res://Scenes/Card/card.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	initialize_hand()

func initialize_hand() -> void:
	# Initialize the hand with a set number of cards
	for i in range(hand_size):
		# Create a new card instance
		var card = Card.instantiate()
		card.set_position(Vector2(i * card_spacing, 0))
		add_child(card)
		


		
