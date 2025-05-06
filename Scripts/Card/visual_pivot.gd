extends Node3D

# Get the camera from the game scene
@onready var camera = get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure we have a camera reference
	if camera:
		# Set the card to be facing the camera
		look_at(camera.global_position, Vector3.UP)
		
		# Apply an additional 180° rotation around Y axis
		rotate_y(PI)
	else:
		push_error("Camera not found!")
