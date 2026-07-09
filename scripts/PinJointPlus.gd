extends Node3D

class_name PinJointPlus

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D

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
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)
	
	MP.mark(objectAPoint.origin,0.6,Color.RED)
	MP.mark(objectBPoint.origin,0.5,Color.GREEN)
	MP.mark(middle.origin,0.4,Color.PURPLE)
	
	
	for i in 1:
		update(1.0)
		pass
	
	
	

func update(del):
	
	#alignToAxis(del)
	
	showMiddle(del)
	
	
	lastFrameTransform = global_transform

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
	
	var aTarget = -(objectAPoint.origin - middle.origin) * TPS
	var bTarget = -(objectBPoint.origin - middle.origin) * TPS
	
	nodeA.linear_velocity -= aVel * del
	nodeB.linear_velocity -= bVel * del
	
	aVel = aTarget * 0.5 + bTarget * 0.5
	bVel = bTarget * 0.5 + aTarget * 0.5
	
	nodeA.linear_velocity += aVel * del
	nodeB.linear_velocity += bVel * del
	
	
	

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
