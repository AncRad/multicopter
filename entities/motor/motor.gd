extends Node3D
class_name Motor

@export
var motor_settings : MotorSettings
@export
var propeller : Propeller
@export_range(0, 1, 0.001)
var throttle : float


func integrate_forces(state : PhysicsDirectBodyState3D, multicopter : Multicopter) -> void:
	var prop_rpm_max : float = propeller.settings.rpm_to_newton_curve.max_domain
	propeller.rpm = prop_rpm_max * throttle
	propeller.integrate_forces(state, multicopter)
