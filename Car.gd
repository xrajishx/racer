extends VehicleBody

export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE = 10.0
export var MAX_STEER = 0.5

func _physics_process(_delta):
	var engine_input = 0.0
	var brake_input = 0.0
	var steer_input = 0.0

	if Input.is_action_pressed("car_forward"):
		engine_input = 1.0
	if Input.is_action_pressed("car_backward"):
		engine_input = -1.0
	if Input.is_action_pressed("car_brake"):
		brake_input = 1.0
		engine_input = 0.0
	if Input.is_action_pressed("car_left"):
		steer_input = 1.0
	elif Input.is_action_pressed("car_right"):
		steer_input = -1.0

	engine_force = engine_input * MAX_ENGINE_FORCE
	brake = brake_input * MAX_BRAKE
	steering = steer_input * MAX_STEER
