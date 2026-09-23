extends Node3D
class_name Propeller

const METER_IN_INCH : float = 0.0254
const AIR_DENSITY : float = 1.225

@export var settings : PropellerSettings
@export var clockwise : bool = false
@export_range(0, 50000, 1000) var rpm : float
@export var root : Node3D


func integrate_forces(state : PhysicsDirectBodyState3D, body : RigidBody3D) -> void:
	## WARNING: RigidBody3D.global_transform != PhysicsDirectBodyState3D.transform -
	## - так как integrate_forces вызывается из физического сервера до этапа синхронизации с узлами !!!
	var transform_local : Transform3D = (global_transform * body.global_transform).orthonormalized()
	var forward_global : Vector3 = transform_local.basis * get_forward_local() * state.transform.basis.orthonormalized()
	
	var static_thrust : float = settings.rpm_to_newton_curve.sample_baked(rpm)
	assert(static_thrust >= 0)
	
	#thrust = mass * speed
	#thrust = volume * density * speed
	#thrust = (square * speed) * density * speed
	
	#thrust / density = (square * speed) * speed
	#thrust / density / square = speed * speed
	#sqrt(thrust / density / square) = speed
	
	var static_flow_volume_per_sec : float = static_thrust / AIR_DENSITY
	var flow_square_m2 : float = (settings.diameter_inch / 2 * METER_IN_INCH) ** 2 * PI
	var static_flow_effective_speed : float = sqrt(static_flow_volume_per_sec / flow_square_m2)
	#var pitch_meter_per_turn : float = settings.pitch_inch_per_turn * METER_IN_INCH
	#var rotation_per_second : float = rpm / 60
	#var static_flow_perfect_speed : float = pitch_meter_per_turn * rotation_per_second
	#var efficiency : float = static_flow_effective_speed / static_flow_perfect_speed
	
	var air_velocity : Vector3 = -(state.linear_velocity + state.angular_velocity.cross(transform_local.origin))
	var air_forward_speed : float = forward_global.dot(air_velocity)
	var air_forward_speed_delta : float = static_flow_effective_speed - (-air_forward_speed)
	
	var dynamic_thrust : float = (flow_square_m2 * static_flow_effective_speed) * AIR_DENSITY * air_forward_speed_delta
	
	
	var torque : float = -dynamic_thrust * 0.05
	if clockwise:
		torque = -torque
	
	if rpm > 0:
		#print('%7.3f' % static_thrust, ' # ', '%7.3f' % dynamic_thrust, ' # ', '%7.3f' % (dynamic_thrust / static_thrust))
		pass
	#return
	
	state.apply_force(forward_global * dynamic_thrust)
	state.apply_torque(forward_global * torque)

func _process(delta : float) -> void:
	var rotation_per_second : float = rpm / 60
	var rotation_per_delta : float = rotation_per_second * delta
	if clockwise:
		rotation_per_delta = -rotation_per_delta
	root.global_basis = root.global_basis.rotated(global_basis * get_forward_local(), rotation_per_delta)

func get_forward_local() -> Vector3:
	assert(settings.forward.is_normalized())
	return settings.forward
