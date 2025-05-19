extends Control

var hand_position: Vector2
var is_animating: bool = false

func return_to_hand():
	if is_animating:
		return

	is_animating = true
	# Create a tween using the scene tree
	var tween = create_tween()
	
	# Configure the tween
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(self, "position", hand_position, 0.5)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	is_animating = false
	
	# If you want to do something after the animation is finished, you can do it here
	print("Animation finished, card returned to hand position.")
