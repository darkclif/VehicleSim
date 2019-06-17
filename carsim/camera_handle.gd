extends Spatial

var curr_angle_change = 0.0 # -1.0 to 1.0
const ANGLE_CHG_SPEED = 2.0
const ANGLE_RET_SPEED = 0.5

func _ready():
	pass

func _process(delta):
	# Return angle to normal
	if self.curr_angle_change != 0:
		var tmp_sign = sign(curr_angle_change)
		self.curr_angle_change += ANGLE_RET_SPEED * -sign(curr_angle_change) * delta
		
		if tmp_sign == 1.0:
			self.curr_angle_change = clamp(self.curr_angle_change, 0.0, 1.0)
		else:
			self.curr_angle_change = clamp(self.curr_angle_change, -1.0, 0.0)
			
	
	# Change angle
	var angle_change = Input.get_action_strength("camera_turn_right") - Input.get_action_strength("camera_turn_left")
	self.curr_angle_change += angle_change * ANGLE_CHG_SPEED * delta
	self.curr_angle_change = clamp(self.curr_angle_change, -1.0, 1.0)
	
	self.rotation = Vector3(0, self.curr_angle_change * (PI/2.0), 0)
