extends RigidBody3D
class_name Multicopter

@export var settings : MulticopterSettings
@export var motors : Array[Motor]
@export_range(0, 1, 0.001) var test_throttle : float

func _integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	
	for motor : Motor in motors:
		motor.throttle = test_throttle
		motor.integrate_forces(state, self)
	
	var air_density : float = 1.225
	var air_velocity : Vector3 = -linear_velocity
	var air_velocity_local : Vector3 = air_velocity * state.transform.basis.orthonormalized()
	var drag_local : Vector3 = settings.drag_coef * (air_velocity_local * air_velocity_local.abs()) * air_density
	var drag : Vector3 = state.transform.basis.orthonormalized() * drag_local
	state.apply_central_force(drag)
