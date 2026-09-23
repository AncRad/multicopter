extends Node3D
class_name Propeller

const METER_IN_INCH : float = 0.0254
const AIR_DENSITY : float = 1.225

@export var settings : PropellerSettings
@export var clockwise : bool = false
@export_range(0, 50000, 1000) var rpm : float


func integrate_forces(state : PhysicsDirectBodyState3D, body : RigidBody3D) -> void:
	var forward : Vector3 = get_forward_local()
	## WARNING: RigidBody3D.global_transform != PhysicsDirectBodyState3D.transform -
	## - так как integrate_forces вызывается из физического сервера до этапа синхронизации с узлами !!!
	var transform_local : Transform3D = (global_transform.orthonormalized() * body.global_transform.orthonormalized()).orthonormalized()
	
	var static_thrust : float = settings.rpm_to_thrust.sample_baked(rpm)
	assert(static_thrust >= 0)
	
	#thrust = mass * speed
	#thrust = volume * density * speed
	#thrust = (square * speed) * density * speed
	
	#thrust / density = (square * speed) * speed
	#thrust / density / square = speed * speed
	#sqrt(thrust / density / square) = speed
	
	var static_flow_volume_per_sec : float = static_thrust / AIR_DENSITY
	var flow_square_m2 : float = (settings.diameter_inch / 2 * METER_IN_INCH) ** 2 * PI
	var static_flow_effective_speed : float = sqrt(static_flow_volume_per_sec / flow_square_m2)
	#var pitch_meter_per_turn : float = settings.pitch_inch_per_turn * METER_IN_INCH
	#var rotation_per_second : float = rpm / 60
	#var static_flow_perfect_speed : float = pitch_meter_per_turn * rotation_per_second
	#var efficiency : float = static_flow_effective_speed / static_flow_perfect_speed
	
	var air_velocity : Vector3 = -(state.linear_velocity + state.angular_velocity.cross(transform_local.origin))
	var air_forward_speed : float = forward.dot(air_velocity)
	
	var air_forward_speed_delta : float = static_flow_effective_speed - (-air_forward_speed)
	#var coef : float = air_forward_speed_delta / static_flow_effective_speed
	#var dynamic_flow_effectiv_speed : float = static_flow_effective_speed * coef
	#var dynamic_flow_effectiv_speed : float = static_flow_effective_speed * (1 - (-air_forward_speed) / static_flow_effective_speed)
	var dynamic_thrust : float = (flow_square_m2 * static_flow_effective_speed) * AIR_DENSITY * air_forward_speed_delta
	
	
	
	if rpm > 0:
		#print(air_forward_speed)
		print('%7.3f' % static_thrust, ' # ', '%7.3f' % dynamic_thrust, ' # ', '%7.3f' % (dynamic_thrust / static_thrust))
		#pass
		#print('%.3f' % static_thrust, ' # ', '%.3f' % efficiency)#, ' # ', '%.3f' % efficiency, ' # ', )
	
	#var static_flow_speed : float = pitch_meter_per_turn * rps
	#static_thrust / AIR_DENSITY / static_flow_speed
	
	
	#var thrust : float = static_thrust# * (1 - (-air_forward_speed) / static_flow_speed)
	
	var forward_global : Vector3 = transform_local.basis * forward * state.transform.basis.orthonormalized()
	#state.apply_force(-forward_global * dynamic_thrust)

func get_forward_local() -> Vector3:
	assert(settings.forward.is_normalized())
	return settings.forward


#Мы вычисляем эффективную площадь «на лету» прямо из кривых, что делает модель полностью самодостаточной:
## 1. Измеряем осевую скорость встречного воздуха
#var forward_air_speed : float = -air_velocity_axial.dot(forward)
## 2. Получаем стендовые параметры для текущих оборотов
#var flow_normal : float = rps_to_flow_curve.sample(rps)
#var volume_normal : float = rps_to_volume_curve.sample(rps)
## 3. Вычисляем эффективную площадь диска на основе стендовых данных
#var calculated_area : float = 0.0
#if not is_zero_approx(flow_normal):
#calculated_area = absf(volume_normal / flow_normal)
## 4. Реальная скорость прохождения воздуха сквозь плоскость винта в полете
## Воздух движется со скоростью потока от винта, но встречный ветер «подталкивает» его
#var flow_speed : float = flow_normal + forward_air_speed
## 5. Реальный объем воздуха в секунду на основе вычисленной площади
#var flow_volume : float = calculated_area * flow_speed
## 6. Масса этого воздуха в секунду
#var flow_mass : float = air_density * absf(flow_volume)
## 7. Изменение скорости потока и финальная тяга
#var flow_speed_delta : float = flow_normal - forward_air_speed
#var thrust : float = flow_mass * flow_speed_delta
