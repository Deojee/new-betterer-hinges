extends Node3D

class_name HingePlus

@export var nodeA : PhysicsBody3D
@export var nodeB : PhysicsBody3D

var lastFrameTransform : Transform3D

var offsetA : Transform3D
var offsetB : Transform3D

#same as before but offset by 1 along the rotation axis
var axisOffsetA : Transform3D
var axisOffsetB : Transform3D


static var numHinges = 0

static var bodiesDict : Dictionary = {}

var rotAxis : Vector3:
	get:
		return global_basis.z
	set(value):
		print("can't change rot axis")

func _ready() -> void:
	
	setup()
	

var isSetup = false
func setup():
	
	if isSetup:
		return
	isSetup = true
	
	if !can_process():
		return
	
	visible = true
	
	lastFrameTransform = global_transform
	
	#Node A in the hinge's local space
	offsetA = global_transform.affine_inverse() * nodeA.global_transform
	offsetB = global_transform.affine_inverse() * nodeB.global_transform
	
	
	#axisOffsetA = global_transform.affine_inverse() * Transform3D(nodeA.global_transform.basis,nodeA.global_transform.origin + rotAxis)
	#axisOffsetB = global_transform.affine_inverse() * Transform3D(nodeB.global_transform.basis,nodeB.global_transform.origin + rotAxis)
	
	var offsetTrans = Transform3D(global_transform.basis,global_transform.origin + rotAxis)
	axisOffsetA = offsetTrans.affine_inverse() * nodeA.global_transform
	axisOffsetB = offsetTrans.affine_inverse() * nodeB.global_transform
	
	nodeA.add_collision_exception_with(nodeB)
	nodeB.add_collision_exception_with(nodeA)
	
	name = str(numHinges) + "th hinge "
	numHinges += 1
	
	if !bodiesDict.has(nodeA):
		bodiesDict[nodeA] = [self]
	else:
		if !bodiesDict[nodeA].has(self):
			bodiesDict[nodeA].append(self)
	
	if !bodiesDict.has(nodeB):
		bodiesDict[nodeB] = [self]
	else:
		if !bodiesDict[nodeB].has(self):
			bodiesDict[nodeB].append(self)
	
	pass



#returns the next hinge in the chain or null
#only checks for other hinges on nodeB
func getNextInChain():
	for body in bodiesDict[nodeB]:
		if body != self:
			return body
	return null

func getAllNextInChain() -> Array:
	var arr = []
	for body in bodiesDict[nodeB]:
		if body != self:
			arr.append( body)
	return arr

var TPS:
	get:
		return Engine.physics_ticks_per_second * 1.0
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)
	
	
	if true:
		if Input.is_action_just_pressed("ui_right"):
			targetAngleDegrees += 15
		if Input.is_action_just_pressed("ui_left"):
			targetAngleDegrees -= 15
		if Input.is_action_just_pressed("ui_up"):
			targetAngleDegrees *= -1
		if Input.is_action_just_pressed("ui_down"):
			targetAngleDegrees += 180
	
	
	
	for i in 5:
		update(1.0)
		pass
	
	return
	$angleLabel.text = str(
		snappedf(
			rad_to_deg(getAngle()),
			0.1
		),
		" d"
		)
	
	

func update(del):
	alignToAxis(del)
	
	showMiddle(del)
	
	adjustTargetSpeed()
	handleMotor(del)
	
	lastFrameTransform = global_transform



#if true; motorSpeedDegrees will be set so that it rotates towards targetAngleDegrees
@export var aimForTarget : bool = true

#whether or not the hinge will try to approach rotation speeds of motorSpeedDegrees
@export var enableMotor : bool = true

##degrees per second
@export var motorSpeedDegrees : float:
	get:
		return rad_to_deg(motorSpeed)
	set(value):
		motorSpeed = deg_to_rad(value)
var motorSpeed = PI

@export var targetAngleDegrees : float:
	get:
		return rad_to_deg(targetAngle)
	set(value):
		targetAngle = fmod(deg_to_rad(value),PI * 2)
var targetAngle = 0 #-PI/4.0


@export var maxMotorSpeedDegrees : float:
	get:
		return rad_to_deg(maxMotorSpeed)
	set(value):
		maxMotorSpeed = deg_to_rad(value)
var maxMotorSpeed = PI

func adjustTargetSpeed():
	
	if !aimForTarget:
		return
	
	var currentAngle = getAngle()
	var PI2 = PI * 2
	
	var difference = angle_difference(currentAngle,targetAngle)
	motorSpeed = abs(difference) * difference * TPS
	
	motorSpeed = clamp(motorSpeed,-maxMotorSpeed,maxMotorSpeed)
	#print(motorSpeed)
	
	pass

func handleMotor(del):
	
	if !enableMotor:
		return
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	var objectAxisAPoint = nodeA.global_transform * axisOffsetA.affine_inverse()
	var objectAxisBPoint = nodeB.global_transform * axisOffsetB.affine_inverse()
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	
	var axis = middle.basis.z
	#along our axis
	var nodeAAngVel = nodeA.angular_velocity.dot(axis)
	var nodeBAngVel = nodeB.angular_velocity.dot(axis)
	
	var rotSpeed = nodeAAngVel - nodeBAngVel
	
	var dif = motorSpeed - rotSpeed
	
	nodeA.angular_velocity += axis * dif * getAPortion(del)# * TPS
	nodeB.angular_velocity -= axis * dif * getBPortion(del)# * TPS
	pass

func alignToAxis(del):
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	var objectAxisAPoint = nodeA.global_transform * axisOffsetA.affine_inverse()
	var objectAxisBPoint = nodeB.global_transform * axisOffsetB.affine_inverse()
	
	#Mathy.draw_debug_sphere(get_tree(),objectAxisAPoint.origin,0.5)
	#Mathy.draw_debug_sphere(get_tree(),objectAxisBPoint.origin,0.5)
	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	var objAAxis = -(objectAPoint.origin - objectAxisAPoint.origin)
	var objectAAngleOffAxis = objAAxis.angle_to(middle.basis.z)
	var objectAAxis
	if objectAAngleOffAxis > 0: # and !nodeA.freeze:
		objectAAxis = (objAAxis.cross(middle.basis.z)).normalized()
		
		#nodeA.angular_velocity -= nodeA.angular_velocity.dot(objectAAxis) * objectAAxis * 0.5
		var dif = (objectAAxis * objectAAngleOffAxis * TPS ) - nodeA.angular_velocity
		nodeA.angular_velocity += dif * getAPortion(del)
		nodeB.angular_velocity -= dif * getBPortion(del)
	
	var objBAxis = -(objectBPoint.origin - objectAxisBPoint.origin)
	var objectBAngleOffAxis = objBAxis.angle_to(middle.basis.z)
	var objectBAxis
	if objectBAngleOffAxis > 0: # and !nodeB.freeze:
		objectBAxis = (objBAxis.cross(middle.basis.z)).normalized()
		
		var dif = (objectBAxis * objectBAngleOffAxis * TPS ) - nodeB.angular_velocity
		
		nodeA.angular_velocity -= dif * getAPortion(del)
		nodeB.angular_velocity += dif * getBPortion(del)
		
	

func getAngle():
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	var angleY = objectAPoint.basis.y.angle_to(objectBPoint.basis.y)
	var angleX = objectAPoint.basis.x.angle_to(objectBPoint.basis.y)
	
	if angleX > PI/2.0:
		return 2.0 * PI - angleY
	else:
		return angleY
	

func getAPortion(del):
	#if nodeA.freeze:
	#	return 0.0
	return (nodeB.mass / (nodeA.mass + nodeB.mass)) * del
func getBPortion(del):
	#if nodeB.freeze:
	#	return 0.0
	return (nodeA.mass / (nodeA.mass + nodeB.mass)) * del

func showMiddle(del):
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)

	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	if Input.is_action_pressed("q"):
		return
	
	
	
	var aTarget = -(objectAPoint.origin - middle.origin) * TPS
	var bTarget = -(objectBPoint.origin - middle.origin) * TPS
	var aTargetDir = aTarget.normalized()
	var bTargetDir = bTarget.normalized()
	
	
	var aDif = aTarget - nodeA.linear_velocity
	var bDif = bTarget - nodeB.linear_velocity
	
	var linearVel = (nodeA.linear_velocity + nodeB.linear_velocity)/20.0
	
	var divisor = 2.0
	
	nodeA.linear_velocity += (aDif) * getAPortion(del)
	nodeB.linear_velocity -= (aDif) * getBPortion(del)
	
	nodeA.linear_velocity -= (bDif) * getAPortion(del)
	nodeB.linear_velocity += (bDif) * getBPortion(del)
	
	
	
	
