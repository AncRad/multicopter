@tool
extends RigidBody3D
class_name Multicopter

@export var settings : MulticopterSettings
@export var controller : Controller
@export var motors : Array[Motor]
@export_range(0, 1, 0.001) var test_throttle : float


func _validate_property(property : Dictionary) -> void:
	if property.name in [&'center_of_mass', &'inertia']:
		property.hint_string = '-1.0,0.0,0.0001,suffix:m'

func _integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	
	controller.integrate_forces(state, self)
	
	for motor : Motor in motors:
		motor.throttle = test_throttle
		motor.integrate_forces(state, self)
	
	var air_density : float = 1.225
	var air_velocity : Vector3 = -linear_velocity
	var air_velocity_local : Vector3 = air_velocity * state.transform.basis.orthonormalized()
	var drag_local : Vector3 = settings.drag_coef * (air_velocity_local * air_velocity_local.abs()) * air_density
	var drag : Vector3 = state.transform.basis.orthonormalized() * drag_local
	if not drag.is_zero_approx():
		state.apply_central_force(drag)
	
	if linear_velocity.length() > 1 != continuous_cd:
		continuous_cd = not continuous_cd
