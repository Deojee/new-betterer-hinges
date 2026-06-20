extends Node3D

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D


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
	
	#Node A in the hinge's local space
	offsetA = global_transform.affine_inverse() * nodeA.global_transform
	offsetB = global_transform.affine_inverse() * nodeB.global_transform
	
	
	#axisOffsetA = global_transform.affine_inverse() * Transform3D(nodeA.global_transform.basis,nodeA.global_transform.origin + rotAxis)
	#axisOffsetB = global_transform.affine_inverse() * Transform3D(nodeB.global_transform.basis,nodeB.global_transform.origin + rotAxis)
	
	var offsetTrans = Transform3D(global_transform.basis,global_transform.origin + rotAxis)
	axisOffsetA = offsetTrans.affine_inverse() * nodeA.global_transform
	axisOffsetB = offsetTrans.affine_inverse() * nodeB.global_transform
	
	pass

var TPS:
	get:
		return Engine.physics_ticks_per_second * 0.5
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
	alignToAxis()
	
	 
	showMiddle()
	
	return
	#offsetA = offsetA.rotated(Vector3.FORWARD,deg_to_rad(motor) * delta)
	#offsetB = offsetB.rotated(Vector3.FORWARD,deg_to_rad(-motor) * delta)
	
	var dict = {nodeA : offsetA,nodeB : offsetB}
	var tolerance = 0.04
	var angTolerance = deg_to_rad(3)
	
	if Input.is_action_just_pressed("mouseLeft"):
		nodeA.global_transform = Spectator.INSTANCE.get_child(0).global_transform
	
	
	var otherNode : RigidBody3D = nodeB
	for node in dict:
		node = node as RigidBody3D
		
		var globalTargetOffset = (
			global_transform #global pos of local trans
			*
			dict[node]
			)
		
		var currentOffset : Transform3D =  ( #just for basis
			globalTargetOffset.affine_inverse() 
			* 
			node.global_transform)
		
		
		var translationOffset = globalTargetOffset.origin - node.global_transform.origin
		var basisQuat = currentOffset.basis.get_rotation_quaternion()
		
		var targetLinVel = (translationOffset) * TPS
		var targetRotVel = -basisQuat.get_angle() * (globalTargetOffset.basis * basisQuat.get_axis()) * TPS
		
		var linVelDif = targetLinVel - node.linear_velocity
		var rotVelDif = targetLinVel - node.angular_velocity
		
		node.linear_velocity += linVelDif * 0.5
		otherNode.linear_velocity -= linVelDif * 0.5
		
		
		
		node.angular_velocity = targetRotVel 
		
		
		
		otherNode = node
	
	

func alignToAxis():
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	var objectAxisAPoint = nodeA.global_transform * axisOffsetA.affine_inverse()
	var objectAxisBPoint = nodeB.global_transform * axisOffsetB.affine_inverse()
	
	Mathy.draw_debug_sphere(get_tree(),objectAxisAPoint.origin,0.5)
	Mathy.draw_debug_sphere(get_tree(),objectAxisBPoint.origin,0.5)
	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	var objAAxis = -(objectAPoint.origin - objectAxisAPoint.origin)
	var objectAAngleOffAxis = objAAxis.angle_to(middle.basis.z)
	var objectAAxis
	if objectAAngleOffAxis > 0:
		objectAAxis = (objAAxis.cross(middle.basis.z)).normalized()
		nodeA.rotate(objectAAxis,objectAAngleOffAxis )
	
	var objBAxis = -(objectBPoint.origin - objectAxisBPoint.origin)
	var objectBAngleOffAxis = objBAxis.angle_to(middle.basis.z)
	var objectBAxis
	if objectBAngleOffAxis > 0:
		objectBAxis = (objBAxis.cross(middle.basis.z)).normalized()
		nodeB.rotate(objectBAxis,objectBAngleOffAxis)
	
	pass

func showMiddle():
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	if Input.is_action_pressed("q"):
		return
	
	nodeA.linear_velocity = -(objectAPoint.origin - middle.origin) * TPS
	nodeB.linear_velocity = -(objectBPoint.origin - middle.origin) * TPS
	
	#nodeA.rotation = middle.basis.get_euler()
	#nodeB.rotation = middle.basis.get_euler()
	
	Mathy.draw_transform(get_tree(),objectAPoint,0.5)
	Mathy.draw_transform(get_tree(),objectBPoint,1.0)
	Mathy.draw_transform(get_tree(),middle,2.0)
	
	pass
	
