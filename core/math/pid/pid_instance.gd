extends Resource
class_name PIDInstance

@export var settings : PIDSettings

var _error_last : Variant
var _error_integral : Variant


func process(error : Variant, delta : float) -> Variant:
	var type : int = typeof(error)
	
	match type:
		TYPE_FLOAT:
			assert(is_finite(error))
			if typeof(_error_last) != type:
				_error_last = error
				_error_integral = 0.0
			
			_error_integral = clampf(_error_integral + error * delta, -settings.integral_limits, settings.integral_limits)
			var error_diverative : float = (error - _error_last) / delta
			_error_last = error
			var solve : float = error * settings.gain_p + _error_integral * settings.gain_i + error_diverative * settings.gain_d
			return solve
		
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			assert(error.is_finite())
			if typeof(_error_last) != type:
				_error_last = error
				_error_integral = error * 0.0
			
			_error_integral = (_error_integral + error * delta).clampf(-settings.integral_limits, settings.integral_limits)
			var error_diverative : Variant = (error - _error_last) / delta
			var solve : Variant = error * settings.gain_p + _error_integral * settings.gain_i + error_diverative * settings.gain_d
			_error_last = error
			return solve
		
		_:
			assert(false)
			return null

func reset() -> void:
	_error_last = null
	_error_integral = null
