#@tool
extends Resource
class_name PIDSettings

#const Type : Dictionary[StringName, StringName] = {
	#&'Variant' : &'Variant',
	#&'Float' : &'Float',
	#&'Vector3' : &'Vector3',
#}

#const TYPE_TO_CODE : Dictionary[StringName, int] = {
	#&'Variant' : TYPE_NIL,
	#&'Float' : TYPE_FLOAT,
	#&'Vector3' : TYPE_VECTOR3,
#}


#@export var type : StringName = Type.Variant:
	#set(value):
		#assert(value in Type)
		#if value != type:
			#type = value
			#notify_property_list_changed()

@export_range(0, 20, 0.1, 'or_greater') var gain_p : float = 1
@export_range(0, 10, 0.1, 'or_greater') var gain_i : float = 0.1
@export_range(0, 0.1, 0.0001, 'or_greater') var gain_d : float = 0.0001
@export_range(0, 10, 0.1, 'or_greater') var integral_limits : float = 0.5
#@export_range(0, 10, 0.1, 'or_greater') var integral_sensitivity : float = 0.


#func _validate_property(property : Dictionary) -> void:
	#if property.name == &'type':
		#property.hint = PROPERTY_HINT_ENUM
		#property.hint_string = ','.join(Type.keys())
	
	#if property.name in [&'gain_p', &'gain_i', &'gain_d']:
		#property.type = TYPE_TO_CODE[type]
		#property.hint = PROPERTY_HINT_RANGE
		#match property.name:
			#&'gain_p':
				#property.hint_string = '0.0,20.0,0.1,or_greater'
			#&'gain_i':
				#property.hint_string = '0.0,10.0,0.01,or_greater'
			#&'gain_d':
				#property.hint_string = '0.0,0.1,0.0001,or_greater'
