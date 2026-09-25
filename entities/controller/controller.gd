extends Node3D
class_name Controller

@export
var settings : ControllerSettings:
	set = set_settings
@export
var config : ControllerConfig:
	set = set_config
@export_range(0, 1, 0.001)
var input_throttle : float:
	set = set_input_throttle
@export_custom(PROPERTY_HINT_RANGE, '-1,1,0.001')
var input_rotation : Vector3:
	set = set_input_rotation

var pid_pitch : PIDInstance = PIDInstance.new()
var pid_yaw : PIDInstance = PIDInstance.new()
var pid_roll : PIDInstance = PIDInstance.new()


func integrate_forces(state : PhysicsDirectBodyState3D, multicopter : Multicopter) -> void:
	var angular_velocity_current : Vector3
	angular_velocity_current.x += state.angular_velocity.dot((state.transform.basis.orthonormalized() * Vector3.MODEL_LEFT).normalized())
	angular_velocity_current.y += state.angular_velocity.dot((state.transform.basis.orthonormalized() * Vector3.MODEL_TOP).normalized())
	angular_velocity_current.z += state.angular_velocity.dot((state.transform.basis.orthonormalized() * Vector3.MODEL_FRONT).normalized())
	
	var angular_velocity_target : Vector3 = input_rotation * config.rc_rate
	
	var angular_velocity_error : Vector3 = angular_velocity_target - angular_velocity_current
	
	var torque_target : Vector3
	torque_target.x = pid_pitch.process(angular_velocity_error.x, state.step)
	torque_target.y = pid_yaw.process(angular_velocity_error.y, state.step)
	torque_target.z = pid_roll.process(angular_velocity_error.z, state.step)
	torque_target /= 10 # FIXME числа слишком большие для смешивания в диапазоне [0, 1].
	
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

func set_config(value : ControllerConfig) -> void:
	if value != config:
		if config:
			config.changed.disconnect(_on_config_changed)
		
		config = value
		
		if config:
			config.changed.connect(_on_config_changed)
		_on_config_changed()

func set_input_throttle(value : float) -> void:
	value = clampf(value, 0, 1)
	if value != input_throttle:
		input_throttle = value

func set_input_rotation(value : Vector3) -> void:
	value = value.clampf(-1, 1) 
	if value != input_rotation:
		input_rotation = value

func _on_settings_changed() -> void:
	if settings:
		pass

func _on_config_changed() -> void:
	if config:
		pid_pitch.settings = config.pid_pitch
		pid_yaw.settings = config.pid_yaw
		pid_roll.settings = config.pid_roll
