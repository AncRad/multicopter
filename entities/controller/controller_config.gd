extends Resource
class_name ControllerConfig

@export
var input_throtte_curve : Curve:
	set(value):
		if value != input_throtte_curve:
			input_throtte_curve = value
			emit_changed()
@export_custom(PROPERTY_HINT_RANGE, '0,1000,10')
var rc_rate : Vector3:
	set(value):
		if value != rc_rate:
			rc_rate = value
			emit_changed()
@export var pid_pitch : PIDSettings:
	set(value):
		if value != pid_pitch:
			pid_pitch = value
			emit_changed()
@export var pid_yaw : PIDSettings:
	set(value):
		if value != pid_yaw:
			pid_yaw = value
			emit_changed()
@export var pid_roll : PIDSettings:
	set(value):
		if value != pid_roll:
			pid_roll = value
			emit_changed()

#@export_custom(PROPERTY_HINT_RANGE, '0.0,20.0,0.01')
#var rc_pid_p : Vector3
#@export_custom(PROPERTY_HINT_RANGE, '0.0,20.0,0.01')
#var rc_pid_i : Vector3
#@export_custom(PROPERTY_HINT_RANGE, '0.0,20.0,0.01')
#var rc_pid_d : Vector3
