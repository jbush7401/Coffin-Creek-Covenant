extends Node3D

var card_being_dragged = null
var initial_mouse_pos = Vector2()
var constant_distance_plane = 25.0  # Distance from camera where the cards should stay
var screen_size: Vector2

@onready var camera_3d: Camera3D = $'../Camera3D'

func _ready():
	# Calculate the optimal constant distance based on your camera's position
	constant_distance_plane = abs(camera_3d.global_position.z - 0.0)
	
	# Initialize screen size
	screen_size = get_viewport().get_visible_rect().size
	
	# Connect to window resize signal to update screen size
	get_tree().get_root().connect("size_changed", Callable(self, "_on_window_size_changed"))
	
	# Initialize all existing cards in the scene
	initialize_all_existing_cards()

# Function to update screen size when window is resized
func _on_window_size_changed():
	screen_size = get_viewport().get_visible_rect().size

func initialize_all_existing_cards():
	# Find all nodes that have "Card" in their name
	var all_nodes = get_tree().get_nodes_in_group("cards")
	
	# Initialize each card
	for card in all_nodes:
		position_card_on_constant_plane(card)

# Call this function whenever a new card is spawned
func _on_card_spawned(card_node):
	position_card_on_constant_plane(card_node)

# Function to position a card on the constant distance plane
func position_card_on_constant_plane(card_node):
	# Get the card's current XY position in world space
	var current_position = card_node.global_position
	
	# Create a ray from the camera through the card's XY position
	var camera_forward = -camera_3d.global_transform.basis.z.normalized()
	var plane_point = camera_3d.global_position + camera_forward * constant_distance_plane
	var plane_normal = camera_forward
	var drag_plane = Plane(plane_normal, plane_point.dot(plane_normal))
	
	# Create a ray from the camera through the card's current XY position projected to screen
	var screen_position = camera_3d.unproject_position(current_position)
	var ray_origin = camera_3d.project_ray_origin(screen_position)
	var ray_direction = camera_3d.project_ray_normal(screen_position)
	
	# Find where this ray intersects our constant distance plane
	var intersection_point = drag_plane.intersects_ray(ray_origin, ray_direction)
	
	if intersection_point:
		card_node.global_position = intersection_point

# Function to clamp a 3D position to stay within screen bounds
func clamp_position_to_screen(pos):
	# Convert the 3D position to screen coordinates
	var screen_pos = camera_3d.unproject_position(pos)
	
	# Define margins (how close to the edge cards can go)
	var margin = Vector2(50, 50)  # 50 pixels from each edge
	
	# Clamp the screen position
	screen_pos.x = clamp(screen_pos.x, margin.x, screen_size.x - margin.x)
	screen_pos.y = clamp(screen_pos.y, margin.y, screen_size.y - margin.y)
	
	# Convert back to 3D position on our plane
	var ray_origin = camera_3d.project_ray_origin(screen_pos)
	var ray_direction = camera_3d.project_ray_normal(screen_pos)
	
	# Create the plane again
	var camera_forward = -camera_3d.global_transform.basis.z.normalized()
	var plane_point = camera_3d.global_position + camera_forward * constant_distance_plane
	var plane_normal = camera_forward
	var drag_plane = Plane(plane_normal, plane_point.dot(plane_normal))
	
	# Find where the ray intersects our plane
	var clamped_position = drag_plane.intersects_ray(ray_origin, ray_direction)
	
	# If intersection fails for some reason, return the original position
	if not clamped_position:
		return pos
		
	return clamped_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			initial_mouse_pos = event.position
			raycast_check_for_card()
		else:
			card_being_dragged = null
	
	elif event is InputEventMouseMotion and card_being_dragged != null:
		update_card_position(event.position)

func raycast_check_for_card():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_ray_origin(mouse_pos)
	var ray_direction = camera_3d.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_direction * 1000
	
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	ray_query.collision_mask = 1  # Match your Area3D's collision layer
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false
	
	var result = space_state.intersect_ray(ray_query)

	if result:
		# Handle both cases: the card itself or its parent might have "Card" in the name
		var card_node = null
		if result.collider.get_parent() and "Card" in result.collider.get_parent().name:
			card_node = result.collider.get_parent()
		
		if card_node:
			handle_card_click(card_node)

func handle_card_click(card_node):
	card_being_dragged = card_node
	
func update_card_position(mouse_pos):
	if not card_being_dragged:
		return
	
	# Calculate ray from camera through mouse position
	var ray_origin = camera_3d.project_ray_origin(mouse_pos)
	var ray_direction = camera_3d.project_ray_normal(mouse_pos)
	
	# Intersect with a plane at a fixed distance from the camera
	var camera_forward = -camera_3d.global_transform.basis.z.normalized()
	var plane_point = camera_3d.global_position + camera_forward * constant_distance_plane
	var plane_normal = camera_forward
	var drag_plane = Plane(plane_normal, plane_point.dot(plane_normal))
	
	# Find intersection with our constant distance plane
	var intersection_point = drag_plane.intersects_ray(ray_origin, ray_direction)
	
	if intersection_point:
		# Apply screen clamping
		var clamped_position = clamp_position_to_screen(intersection_point)
		
		# Update the position with clamped coordinates
		card_being_dragged.global_position = clamped_position
		
