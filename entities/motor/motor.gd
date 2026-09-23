extends Node3D
class_name Motor

@export var motor_settings : MotorSettings
@export var propeller : Propeller


func integrate_forces(state : PhysicsDirectBodyState3D, body : RigidBody3D) -> void:
	propeller.integrate_forces(state, body)
