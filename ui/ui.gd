extends Control

# UI Shortcuts
var bar_brake
var bar_throttle 
var bar_turn

var vect_handler = {}
var speed_label
var acc_label
var engforce_label

var cm = {}
var cm_num = {}

func _ready():
	# Make shortcuts
	self.bar_brake = $vbox_input/hbox/progress_brake
	self.bar_throttle = $vbox_input/hbox2/progress_throttle
	self.bar_turn = $vbox_input/hbox3/progress_turn

	self.vect_handler["traction"] = $hbox_stats/vbox_data/traction_vect
	self.vect_handler["drag"] = $hbox_stats/vbox_data/drag_vect
	self.vect_handler["friction"] = $hbox_stats/vbox_data/friction_vect
	
	self.speed_label = $hbox_stats/vbox_data/speed
	self.acc_label = $hbox_stats/vbox_data/acc
	self.engforce_label = $hbox_stats/vbox_data/engforce
	
	self.cm["front"] = $cm_front
	self.cm["rear"] = $cm_rear
	self.cm_num["front"] = $cm_front_num
	self.cm_num["rear"] = $cm_rear_num
	
	# Make global ref
	globals.ui = self

func set_center_mass(name, value):
	self.cm[name].set_value(value)
	
func set_cm_number(name, value):
	self.cm_num[name].text = str("%4.0f\nNm" % value)

func set_vector(name, vect):
	self.vect_handler[name].text = str(vect)

func set_speed(speed):
	self.speed_label.text = str("%.2f" % speed) + " m/s " + ("(%.2f km/h)" % (speed * 3600 / 1000))

func set_acc(acc):
	self.acc_label.text = str("%.2f" % acc) + " m/s " + ("(%.2f km/h)" % (acc * 3600 / 1000))

func set_engforce(force):
	self.engforce_label.text = str("%.2f N" % force)

func _process(delta):
	self.bar_brake.set_value(Input.get_action_strength("car_brake") * 100)
	self.bar_throttle.set_value(Input.get_action_strength("car_throttle") * 100)
	self.bar_turn.set_value(0.5 * (1.0 + Input.get_action_strength("car_turn_right") - Input.get_action_strength("car_turn_left")) * 100)