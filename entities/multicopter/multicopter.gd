extends RigidBody3D
class_name Multicopter

@export var motors : Array[Motor]
@export_range(0, 1, 0.01) var test_throttle : float

func _integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	
	
	for motor : Motor in motors:
		#motor.propeller.rpm = 20000 * test_throttle
		motor.integrate_forces(state, self)
