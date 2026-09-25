extends Node3D
class_name Controller

@export
var settings : ControllerSettings
@export
var config : ControllerConfig
@export_range(0, 1, 0.001)
var input_throttle : float
@export_custom(PROPERTY_HINT_RANGE, '-1,1,0.001')
var input_rotation : Vector3

var pid_pitch : PIDInstance
var pid_yaw : PIDInstance
var pid_roll : PIDInstance


func integrate_forces(state : PhysicsDirectBodyState3D, multicopter : Multicopter) -> void:
	var angular_velocity_current : Vector3
	angular_velocity_current.x += (state.transform.basis.orthonormalized() * Vector3.MODEL_RIGHT).dot(state.angular_velocity)
	angular_velocity_current.y += (state.transform.basis.orthonormalized() * Vector3.MODEL_TOP).dot(state.angular_velocity)
	angular_velocity_current.z += (state.transform.basis.orthonormalized() * Vector3.MODEL_FRONT).dot(state.angular_velocity)
	
	var angular_velocity_target : Vector3 = input_rotation * config.rc_rate
	
	var angular_velocity_error : Vector3 = angular_velocity_target - angular_velocity_current
	
	var torque_target : Vector3
	torque_target.x = pid_pitch.process(angular_velocity_error.x, state.step)
	torque_target.y = pid_yaw.process(angular_velocity_error.y, state.step)
	torque_target.z = pid_roll.process(angular_velocity_error.z, state.step)
	
	# Коэффициенты смешивания
	# Vector4(pitch, yaw, roll, throttle) без учета направления вращения пропеллера и мотора
	const MOTOR_MIXING_DEFAULT : Array[Vector4] = [
		Vector4(+1, +1, +1, +1),
		Vector4(+1, +1, -1, +1),
		Vector4(-1, +1, +1, +1),
		Vector4(-1, +1, -1, +1),
	]
	var motor_mixing : Array[Vector4] = MOTOR_MIXING_DEFAULT.duplicate()
	# Поправка смешивания по направлению вращения
	for i in multicopter.motors.size():
		if not multicopter.motors[i].propeller.clockwise:
			motor_mixing[i].y = -motor_mixing[i].y
	# Смешивание
	var motors_throttle : Array[float]
	motors_throttle.resize(multicopter.motors.size())
	for i in multicopter.motors.size():
		motors_throttle[i] += torque_target.x * motor_mixing[i].x
		motors_throttle[i] += torque_target.y * motor_mixing[i].y
		motors_throttle[i] += torque_target.z * motor_mixing[i].z
		motors_throttle[i] += input_throttle * motor_mixing[i].w
	# Выравнивание
	var motor_throttle_min : float = motors_throttle.min()
	if motor_throttle_min < 0:
		for i in motors_throttle.size():
			motors_throttle[i] -= motor_throttle_min
	var motor_throttle_max : float = motors_throttle.max()
	if motor_throttle_max > 1:
		for i in motors_throttle.size():
			motors_throttle[i] /= motor_throttle_max
	# Ограничение
	for i in motors_throttle.size():
		if motors_throttle[i] < -0.001 or motors_throttle[i] > 1.001:
			push_warning()
		motors_throttle[i] = clampf(motors_throttle[i], config.throttle_minimum, 1)
	# Применение
	for i in multicopter.motors.size():
		multicopter.motors[i].throttle = motors_throttle[i]

func set_settings(value : ControllerSettings) -> void:
	if value != settings:
		if settings:
			settings.changed.disconnect(_on_settings_changed)
		
		settings = value
		
		if settings:
			settings.changed.connect(_on_settings_changed)
		_on_settings_changed()

func _on_settings_changed() -> void:
	if settings:
		pid_pitch.settings = settings.pid_pitch
		pid_yaw.settings = settings.pid_yaw
		pid_roll.settings = settings.pid_roll
