extends Node3D
class_name Spectator

var velocity = Vector3.ZERO
@export var cam : Camera3D

const SPEED = 30
const SPRINT_SPEED = 100
const ACCEL = 5.0

static var INSTANCE

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	INSTANCE = self

var pause = false

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("pause"):
		
		pause = !pause
		
		if !pause:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	
	

@export var projectileScene : PackedScene

var fireRate = 5
var cooldown = 0.0
func _physics_process(delta: float) -> void:
	
	if false and Input.is_action_just_pressed("mouseRight"):
		#print("\n ", Engine.get_physics_frames() ,"\n")
		pass
	
	var b = cam.global_basis
	
	# Get input direction vector in local space
	var input_dir = -Vector3(
		Input.get_axis("d", "a"),   # x-axis (left/right)
		Input.get_axis("space", "shift"),  # y-axis (up/down)
		Input.get_axis("s", "w")    # z-axis (forward/backward)
	)
	
	
	# Transform input direction from local to global space using the basis
	var target = b * input_dir
	
	if pause:
		target = Vector3.ZERO
	
	
	if Input.is_action_pressed("mouseLeft"):
		target *= SPRINT_SPEED
	else:
		target *= SPEED
	
	if Input.is_action_pressed("t"):
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1
	
	velocity = lerp(velocity,target, delta * ACCEL * (1.0/Engine.time_scale))
	
	position += velocity * delta * (1.0/Engine.time_scale)
	
	if cooldown:
		cooldown -= delta
	if Input.is_action_pressed("e") and cooldown <= 0:
		cooldown = 1.0/fireRate
		var proj : RigidBody3D = projectileScene.instantiate()
		
		
		get_parent().add_child(proj)
		proj.transform = $cam.global_transform 
		proj.transform.origin += $cam.global_basis.z * -2.0
		
		proj.linear_velocity = -$cam.global_basis.z * 50
		
		var killTween = get_tree().create_tween()
		killTween.tween_callback(proj.queue_free).set_delay(2.0)
		
		
		
	
	
	pass

var sensX = 0.001
var sensY = 0.001

func _input(event: InputEvent) -> void:
	
	if pause:
		return
	
	if event is InputEventMouseMotion:
		cam.rotate_x(-event.relative.y * sensY)
		rotation.y += -event.relative.x * sensX
		
	



func _notification(what):
	
	return
	
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if not get_tree().paused:
			get_tree().paused = true
	
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not get_tree().paused:
			get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		get_tree().paused = false
