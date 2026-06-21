extends Node3D

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D

var lastFrameTransform : Transform3D

var offsetA : Transform3D
var offsetB : Transform3D

#same as before but offset by 1 along the rotation axis
var axisOffsetA : Transform3D
var axisOffsetB : Transform3D

##degrees per second
var motor = 5

var rotAxis : Vector3:
	get:
		return global_basis.z
	set(value):
		print("can't change rot axis")

func _ready() -> void:
	
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
	
	pass

var TPS:
	get:
		return Engine.physics_ticks_per_second * 1.0
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
	alignToAxis()
	
	 
	showMiddle()
	
	lastFrameTransform = global_transform

func alignToAxis():
	
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
	if objectAAngleOffAxis > 0 and !nodeA.freeze:
		objectAAxis = (objAAxis.cross(middle.basis.z)).normalized()
		
		#nodeA.angular_velocity -= nodeA.angular_velocity.dot(objectAAxis) * objectAAxis * 0.5
		var dif = (objectAAxis * objectAAngleOffAxis * TPS ) - nodeA.angular_velocity
		nodeA.angular_velocity += dif/2.0
		nodeB.angular_velocity -= dif/2.0
	
	var objBAxis = -(objectBPoint.origin - objectAxisBPoint.origin)
	var objectBAngleOffAxis = objBAxis.angle_to(middle.basis.z)
	var objectBAxis
	if objectBAngleOffAxis > 0 and !nodeB.freeze:
		objectBAxis = (objBAxis.cross(middle.basis.z)).normalized()
		
		var dif = (objectBAxis * objectBAngleOffAxis * TPS ) - nodeB.angular_velocity
		
		nodeA.angular_velocity -= dif/2.0
		nodeB.angular_velocity += dif/2.0
		
	

func showMiddle():
	
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
	
	nodeA.linear_velocity += (aDif)/divisor
	nodeB.linear_velocity -= (aDif)/divisor
	
	nodeA.linear_velocity -= (bDif)/divisor
	nodeB.linear_velocity += (bDif)/divisor
	
	
	
	#nodeA.linear_velocity = aTarget
	#nodeB.linear_velocity = bTarget
	#prints("before:",nodeB.linear_velocity)
	
	
	#prints(bTarget.length(),nodeB.linear_velocity.dot(bTargetDir))
	#prints("after:",nodeB.linear_velocity)
	
	#Mathy.draw_debug_sphere(get_tree(),nodeB.global_position + nodeB.linear_velocity/TPS,0.5,Color.LIME)
	
	#nodeA.rotation = middle.basis.get_euler()
	#nodeB.rotation = middle.basis.get_euler()
	
	#Mathy.draw_transform(get_tree(),objectAPoint,0.5)
	#Mathy.draw_transform(get_tree(),objectBPoint,1.0)
	#Mathy.draw_transform(get_tree(),middle,2.0)
	
	
	
	
