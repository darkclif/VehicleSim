extends RigidBody

var in_throttle = 0.0
var in_brake 	= 0.0
var in_turn = 0.0

var v_direction = Vector3(0, 0, 1)
const GRAVITY = 9.80 # m / s^2
const TURN_ANGLE = (33.0 / 360.0) * (2.0 * PI)

########################################## Data
# Current data
var v_speed = Vector3(0, 0, 0)
var c_rpm = 0 # round / minute
var c_torque = 161 # N * m
var c_curr_gear = 0

var c_w_axle_front = 0.0 # fill in _ready function!
var c_w_axle_rear = 0.0 # fill in _ready function!

# Car const data
var c_drag = 0.34
var c_friction = 30 * c_drag
var c_mass = 1100.0 # kg

var c_wheel_radius = 0.34 # m
var c_tyre_fric = 1.0
var c_wheelbase = 2.362 # m (odleglosc pomiedzy kolami)
var c_cm_height = 1.0 # m (wysokosc srodka ciezkosci)
var c_cm_rear = 0.4 # m (stosunek odleglosci przedniej osi od CM do c_wheelbase)

var c_trans_efficiency = 0.8
var c_diff_ratio = 3.42

var c_gears_ratio = [
	3.909,
	2.055,
	1.342,
	0.964,
	0.780
]

########################################## Functions
func _ready():
	# Center mass
	self.c_w_axle_front = (1.0 - c_cm_rear) * GRAVITY * c_mass
	self.c_w_axle_rear = c_cm_rear * GRAVITY * c_mass

func process_input():
	self.in_throttle = Input.get_action_strength("car_throttle")
	self.in_brake = Input.get_action_strength("car_brake")
	self.in_turn = Input.get_action_strength("car_turn_right") - Input.get_action_strength("car_turn_left")

func _process(delta):
	self.process_input()
	
	# Spin wheels
	var rps = v_speed.length() / c_wheel_radius
	$wheel_lf/mesh.rotation.x += delta * rps
	$wheel_lf/mesh.rotation.y = -TURN_ANGLE * in_turn
	$wheel_rf/mesh.rotation.x += delta * rps
	$wheel_rf/mesh.rotation.y = -TURN_ANGLE * in_turn
	$wheel_rr/mesh.rotation.x += delta * rps
	$wheel_lr/mesh.rotation.x += delta * rps

func _physics_process(delta):
	#### Car mechanics ####
	# Break
	var f_break = Vector3(0, 0, 0)
	if v_speed.z > 0:
		f_break = -v_direction * in_brake * 5000.0
	
	# Traction
	var f_engine = (c_torque * c_gears_ratio[c_curr_gear] * c_diff_ratio * c_trans_efficiency) / c_wheel_radius
	
	var traction = v_direction * f_engine * in_throttle
	traction = Vector3(0, 0, min(c_w_axle_front, traction.length()))
	
	# Drag
	var drag = -v_speed * v_speed.length() * c_drag
	
	# Friction
	var friction = -c_friction * v_speed
	
	# Acceleration
	var acc = (f_break + traction + drag + friction) / self.c_mass
	
	# Weight transfer
	var dir_sign = sign(cos(acc.angle_to(v_direction)))
	self.c_w_axle_front = 	(1.0 - c_cm_rear) * GRAVITY * c_mass - (c_cm_height/c_wheelbase) * c_mass * acc.length() * dir_sign
	self.c_w_axle_rear = 			c_cm_rear * GRAVITY * c_mass + (c_cm_height/c_wheelbase) * c_mass * acc.length() * dir_sign

	# Change position
	self.v_speed += delta * acc
	self.translate(delta * v_speed)
	
	# Rotate
	var turn_angle = in_turn * TURN_ANGLE
	var r = 0.0
	var omega = 0.0
	if abs(sin(turn_angle)) > 0.05:
		r = c_wheelbase / sin(turn_angle)
		omega = v_speed.length() / r
	
	var center = Vector3(0, 0, -0.7) + Vector3(sign(-in_turn), 0, 0) * (abs(turn_angle) / TURN_ANGLE) * 100
	
	print(center, " r:", r, " o:", omega)
	self.global_rotate(Vector3(0,1,0), -delta * omega)
	
	###### DEBUG ######
	# Show data
	globals.get_ui().set_vector("traction", traction)
	globals.get_ui().set_vector("drag", drag)
	globals.get_ui().set_vector("friction", friction)
	
	globals.get_ui().set_speed(self.v_speed.length())
	globals.get_ui().set_acc(acc.length())
	globals.get_ui().set_engforce(f_engine)
	
	globals.get_ui().set_center_mass("front", 100 * (self.c_w_axle_front / (GRAVITY * c_mass)))
	globals.get_ui().set_center_mass("rear", 100 * (self.c_w_axle_rear / (GRAVITY * c_mass)))
	globals.get_ui().set_cm_number("front", self.c_w_axle_front)
	globals.get_ui().set_cm_number("rear", self.c_w_axle_rear)
	
	# Draw forces
	$debug_vectors.update_arrow("speed", 	v_speed, Color.blue) 
	#$debug_vectors.update_arrow("traction", v_speed, Color.cornsilk) 
	#$debug_vectors.update_arrow("drag", 	v_speed, Color.white) 
	#$debug_vectors.update_arrow("friction", v_speed, Color.blue) 
