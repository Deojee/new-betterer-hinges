extends Node3D

class_name PinJointPlus

@export var node : RigidBody3D
@export var pinPoint : Node3D

var lastFrameTransform : Transform3D

var offset : Transform3D

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
	offset = global_transform.affine_inverse() * node.global_transform
	
	name = str(numHinges) + "th hinge "
	numHinges += 1
	
	



var TPS:
	get:
		return Engine.physics_ticks_per_second * 1.0
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
	var objectAPoint = node.global_transform * offset.affine_inverse()
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)
	
	MP.mark(objectAPoint.origin,0.6,Color.RED)
	
	MP.mark(pinPoint.global_transform.origin,0.7,Color.GREEN)
	
	
	for i in 1:
		update(1.0)
		pass
	
	
	

func update(del):
	
	#alignToAxis(del)
	
	showMiddle(del)
	
	
	lastFrameTransform = global_transform


func showMiddle(del):
	
	var objectPoint := node.global_transform * offset.affine_inverse()
	
	var nodeToPoint := node.global_position - objectPoint.origin
	var nodeToTarget := node.global_position - pinPoint.global_position
	
	var axis = nodeToPoint.cross(nodeToTarget)
	if axis != Vector3.ZERO:
		node.rotate(axis.normalized(), nodeToPoint.angle_to(nodeToTarget) )
	

	
	var target = pinPoint.global_position
	
	var targetVel = -(objectPoint.origin - target) #* TPS
	
	
	
	node.global_position += targetVel
	#apply_force_from_pos(node,objectPoint.origin,targetVel * 2)
	
	

func apply_force_from_pos(body : PhysicsBody3D, globForcePos,globForce):
	body.linear_velocity += globForce
	var bodyCenterOfMass = body.global_transform
	if body is RigidBody3D:
		bodyCenterOfMass = body.global_transform * body.center_of_mass
	body.angular_velocity += (globForcePos - bodyCenterOfMass).cross(globForce);

func getTorqueFromPos(body : PhysicsBody3D, globForcePos,globForce):
	var bodyCenterOfMass = body.global_position
	if body is RigidBody3D:
		bodyCenterOfMass = body.global_transform * body.center_of_mass
	return (globForcePos - bodyCenterOfMass).cross(globForce);
