extends Resource
class_name PropellerSettings

@export
var forward : Vector3 = Vector3.MODEL_FRONT
@export_range(0.1, 10, 0.1, 'suffix:дюйм')
var diameter_inch : float = 1
@export_range(0.1, 10, 0.1, 'suffix:дюйм на оборот')
var pitch_inch_per_turn : float = 1
@export_range(0, 0.1, 0.0001)
var torque_factor : float = 0.05
@export
var rpm_to_newton_curve : Curve
