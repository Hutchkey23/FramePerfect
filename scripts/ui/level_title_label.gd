extends RichTextLabel

var time : float = 0.0

const WOBBLE_FACTOR : float = 6.0

func _process(delta: float) -> void:
	time += delta
	
	rotation_degrees = sin(5 * time) * WOBBLE_FACTOR
