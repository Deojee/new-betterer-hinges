extends Node3D

class_name PinJointPlus

@export var nodeA : PhysicsBody3D
@export var nodeB : PhysicsBody3D

var lastFrameTransform : Transform3D

var offsetA : Transform3D
var offsetB : Transform3D

#same as before but offset by 1 along the rotation axis
#var axisOffsetA : Transform3D
#var axisOffsetB : Transform3D


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
	
	#var offsetTransA = Transform3D(global_transform.basis,global_transform.origin + rotAxis)
	
	#axisOffsetA = offsetTrans.affine_inverse() * nodeA.global_transform
	#axisOffsetB = offsetTrans.affine_inverse() * nodeB.global_transform
	
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
	
	MP.mark(objectAPoint.origin,0.5,Color.RED)
	MP.mark(objectBPoint.origin,0.5,Color.GREEN)
	
	
	for i in 1:
		update(1.0)
		pass
	
	
	

func update(del):
	
	#alignToAxis(del)
	
	showMiddle(del)
	
	
	lastFrameTransform = global_transform





func alignToAxis(del):
	
	#point where object A wants the pinjoint to be
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	
	#var objectAxisAPoint = nodeA.global_transform * axisOffsetA.affine_inverse()
	#var objectAxisBPoint = nodeB.global_transform * axisOffsetB.affine_inverse()
	
	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	var objAToMiddle = middle.origin - nodeA.global_position
	var objAToPoint = objectAPoint.origin - nodeA.global_position
	
	var objBToMiddle = middle.origin - nodeB.global_position
	var objBToPoint = objectBPoint.origin - nodeB.global_position
	
	#var objAAxis = -(objectAPoint.origin - objectAxisAPoint.origin)
	var objectAAngleOffAxis = objAToMiddle.angle_to(objAToPoint)
	var objectAAxis
	if objectAAngleOffAxis > 0: # and !nodeA.freeze:
		objectAAxis = (objAToMiddle.cross(objAToPoint)).normalized()
		
		#nodeA.angular_velocity -= nodeA.angular_velocity.dot(objectAAxis) * objectAAxis * 0.5
		var dif = (objectAAxis * objectAAngleOffAxis * TPS ) - nodeA.angular_velocity
		nodeA.angular_velocity += dif * getAPortion(del)
		nodeB.angular_velocity -= dif * getBPortion(del)
	
	#var objBAxis = -(objectBPoint.origin - objectAxisBPoint.origin)
	var objectBAngleOffAxis = objBToMiddle.angle_to(objBToPoint)
	var objectBAxis
	if objectBAngleOffAxis > 0: # and !nodeB.freeze:
		objectBAxis = (objBToMiddle.cross(objBToPoint)).normalized()
		
		var dif = (objectBAxis * objectBAngleOffAxis * TPS ) - nodeB.angular_velocity
		
		nodeA.angular_velocity -= dif * getAPortion(del)
		nodeB.angular_velocity += dif * getBPortion(del)
		
	



func getAPortion(del):
	#if nodeA.freeze:
	#	return 0.0
	return (nodeB.mass / (nodeA.mass + nodeB.mass)) * del
func getBPortion(del):
	#if nodeB.freeze:
	#	return 0.0
	return (nodeA.mass / (nodeA.mass + nodeB.mass)) * del

var aVel : Vector3
var bVel : Vector3
var aAng : Vector3
var bAng : Vector3

func showMiddle(del):
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)

	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	if Input.is_action_pressed("q"):
		return
	
	nodeA.linear_velocity -= aVel
	nodeA.angular_velocity -= aAng
	nodeB.linear_velocity -= bVel
	nodeB.angular_velocity -= bAng
	
	var aTarget = -(objectAPoint.origin - middle.origin) * TPS
	var bTarget = -(objectBPoint.origin - middle.origin) * TPS
	
	
	#aVel = aTarget * getAPortion(del) - bTarget * getBPortion(del)
	#bVel = -aTarget * getAPortion(del) + bTarget * getBPortion(del)
	aVel = aTarget * getAPortion(del) 
	bVel = bTarget * getBPortion(del)
	
	aAng = getTorqueFromPos(nodeA,objectAPoint.origin,aVel) * 0.25
	aAng += getTorqueFromPos(nodeA,objectAPoint.origin,-bVel) * 0.25
	
	bAng = getTorqueFromPos(nodeB,objectAPoint.origin,bVel) * 0.25
	bAng += getTorqueFromPos(nodeB,objectAPoint.origin,-aVel) * 0.25
	
	aVel -= bTarget * getBPortion(del) 
	bVel -= aTarget * getAPortion(del)
	
	nodeA.linear_velocity += aVel
	nodeA.angular_velocity += aAng
	nodeB.linear_velocity += bVel
	nodeB.angular_velocity += bAng
	
	#apply_force_from_pos(nodeB,objectAPoint.origin,-aTarget * getAPortion(del))
	#apply_force_from_pos(nodeA,objectBPoint.origin,-bTarget * getBPortion(del))
	
	return
	var aTargetDir = aTarget.normalized()
	var bTargetDir = bTarget.normalized()
	
	
	nodeA.linear_velocity -= aVel
	nodeB.linear_velocity -= bVel
	
	var aDif = aTarget - nodeA.linear_velocity
	var bDif = bTarget - nodeB.linear_velocity
	
	var linearVel = (nodeA.linear_velocity + nodeB.linear_velocity)/20.0
	
	var divisor = 2.0
	
	aVel = (aDif) * getAPortion(del) - (bDif) * getBPortion(del)
	bVel = -(aDif) * getAPortion(del) + (bDif) * getBPortion(del)
	
	nodeA.linear_velocity += aVel
	nodeB.linear_velocity += bVel
	
	
	
	

func apply_force_from_pos(body : PhysicsBody3D, globForcePos,globForce):
	body.linear_velocity += globForce
	var bodyCenterOfMass = body.global_position
	if body is RigidBody3D:
		bodyCenterOfMass = body.global_transform * body.center_of_mass
	body.angular_velocity += (globForcePos - bodyCenterOfMass).cross(globForce);

func getTorqueFromPos(body : PhysicsBody3D, globForcePos,globForce):
	var bodyCenterOfMass = body.global_position
	if body is RigidBody3D:
		bodyCenterOfMass = body.global_transform * body.center_of_mass
	return (globForcePos - bodyCenterOfMass).cross(globForce);
