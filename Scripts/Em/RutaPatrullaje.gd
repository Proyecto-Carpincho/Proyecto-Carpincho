extends Path2D
class_name RutaPatrullaje

var loop:bool

func _ready() -> void:
	if self.curve.get_point_position(0) == curve.get_point_position(curve.point_count - 1):
		loop = true

func is_looping() -> bool:
	if self.curve.get_point_position(0) == curve.get_point_position(curve.point_count - 1):
		return true
	else:
		return false
