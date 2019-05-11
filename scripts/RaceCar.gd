extends VehicleBody

signal respawn

export var MAX_ENGINE_FORCE = 100.0
export var MAX_BRAKE = 10.0
export var MAX_STEER = 0.3

export var STEER_SPEED = 3.0

var material = load("res://assets/outline.material")

func _enter_tree():
	var outline_mesh = $CarBodyMesh.mesh.create_outline(0.05)
	var outline_mesh_instance = MeshInstance.new()
	outline_mesh_instance.set_mesh(outline_mesh)
	outline_mesh_instance.set_surface_material(0, material)
	outline_mesh_instance.transform = $CarBodyMesh.transform
	add_child(outline_mesh_instance)

func _ready():
	$AudioStreamPlayer.volume_db = global.default_car_audio_volume
	$AudioStreamPlayer.pitch_scale = global.default_car_audio_pitch_scale

func _input(event):
	if event.is_action_pressed("car_respawn"):
		emit_signal("respawn")

func _physics_process(delta):
	if !$AudioStreamPlayer.playing and linear_velocity.length() * delta >= 0.0:
		$AudioStreamPlayer.play()

	$AudioStreamPlayer.pitch_scale = clamp(linear_velocity.length() * delta / 2, 0.01, 0.6)
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

	var steer_change = STEER_SPEED * MAX_STEER * delta
	if steer_input != 0.0:
		steering = clamp(steering + (steer_input * steer_change), -MAX_STEER, MAX_STEER)
	else:
		if steering > 0.1:
			steering -= steer_change
		elif steering < -0.1:
			steering += steer_change
		else:
			steering = 0.0