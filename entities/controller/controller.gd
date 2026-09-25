extends Node3D
class_name Controller

@export
var settings : ControllerSettings
@export
var config : ControllerConfig

var pid_pitch : PIDInstance
var pid_yaw : PIDInstance
var pid_roll : PIDInstance


func integrate_forces(state : PhysicsDirectBodyState3D, multicopter : Multicopter) -> void:
	pass

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
