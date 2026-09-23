extends Resource
class_name PropellerSettings

@export var forward : Vector3 = Vector3.MODEL_FRONT
@export_range(0.1, 10, 0.1, 'suffix:дюйм')
var diameter_inch : float = 1
@export_range(0.1, 10, 0.1, 'suffix:дюйм на оборот')
var pitch_inch_per_turn : float = 1
@export var rps_to_volume_curve : Curve
@export var rps_to_flow_curve : Curve
@export var rpm_to_thrust : Curve
