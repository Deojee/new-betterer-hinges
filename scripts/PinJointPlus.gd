extends Node3D

class_name PinJointPlus

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D

var offsetA : Transform3D
var offsetB : Transform3D

#same as before but offset by 1 along the rotation axis
#var axisOffsetA : Transform3D
#var axisOffsetB : Transform3D



func _ready() -> void:
	
	setup()
	

func setup():
	
	
	if !can_process():
		return
	
	visible = true
	
	
	#Node A in the hinge's local space
	offsetA = global_transform.affine_inverse() * nodeA.global_transform
	offsetB = global_transform.affine_inverse() * nodeB.global_transform
	
	
	
	


var TPS:
	get:
		return Engine.physics_ticks_per_second * 1.0
	set(value):
		print("Please set TPS in physics/common")

var enabled = false:
	get:
		return enabled
	set(value):
		if value:
			setup()
		enabled = value

func _physics_process(delta: float) -> void:
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	#Mathy.draw_line_between(get_tree(),objectAPoint.origin,nodeA.global_position,0.3,Color.RED)
	#Mathy.draw_line_between(get_tree(),objectBPoint.origin,nodeB.global_position,0.3,Color.BLUE)
	
	#MP.mark(objectAPoint.origin,0.5,Color.RED)
	#MP.mark(objectBPoint.origin,0.5,Color.GREEN)
	
	if !enabled:
		return
	
	for i in 1:
		update(1.0)
		pass
	
	
	

func update(del):
	alignToAxis(del)
	
	showMiddle(del)
	



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
	if nodeA.freeze:
		return 0.0
	if nodeB.freeze:
		return 1.0
	return (nodeB.mass / (nodeA.mass + nodeB.mass)) * del
func getBPortion(del):
	if nodeB.freeze:
		return 0.0
	if nodeA.freeze:
		return 1.0
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
	
	nodeA.linear_velocity += (aDif) * getAPortion(del)
	nodeB.linear_velocity -= (aDif) * getBPortion(del)
	
	nodeA.linear_velocity -= (bDif) * getAPortion(del)
	nodeB.linear_velocity += (bDif) * getBPortion(del)
	
	
	
	
