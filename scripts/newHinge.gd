extends Node3D

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D

var offsetA : Transform3D
var offsetB : Transform3D

##degrees per second
var motor = 5

func _ready() -> void:
	
	#Node A in the hinge's local space
	offsetA = global_transform.affine_inverse() * nodeA.global_transform
	offsetB = global_transform.affine_inverse() * nodeB.global_transform
	
	
	pass

var TPS:
	get:
		return Engine.physics_ticks_per_second * 0.5
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
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
	
	

func showMiddle():
	
	var objectAPoint = nodeA.global_transform * offsetA.affine_inverse()
	var objectBPoint = nodeB.global_transform * offsetB.affine_inverse()
	
	
	var middle = objectAPoint.interpolate_with(objectBPoint,0.5)
	
	if Input.is_action_pressed("q"):
		return
	
	nodeA.linear_velocity = -(objectAPoint.origin - middle.origin) * TPS
	nodeB.linear_velocity = -(objectBPoint.origin - middle.origin) * TPS
	
	nodeA.rotation = middle.basis.get_euler()
	nodeB.rotation = middle.basis.get_euler()
	
	Mathy.draw_transform(get_tree(),objectAPoint,0.5)
	Mathy.draw_transform(get_tree(),objectBPoint,1.0)
	Mathy.draw_transform(get_tree(),middle,2.0)
	
	pass
	
