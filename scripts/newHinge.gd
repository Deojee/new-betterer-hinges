extends Node3D

@export var nodeA : RigidBody3D
@export var nodeB : RigidBody3D

var offsetA : Transform3D
var offsetB : Transform3D

func _ready() -> void:
	
	#Node A in the hinge's local space
	offsetA = global_transform.affine_inverse() * nodeA.global_transform
	offsetB = global_transform.affine_inverse() * nodeB.global_transform
	
	
	pass

var TPS:
	get:
		return Engine.physics_ticks_per_second * 0.98
	set(value):
		print("Please set TPS in physics/common")

func _physics_process(delta: float) -> void:
	
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
		
		var linVelDif = node.linear_velocity - targetLinVel
		var rotVelDif = node.angular_velocity - targetLinVel
		
		node.linear_velocity -= linVelDif
		node.angular_velocity -= rotVelDif 
		
		
		
		otherNode = node
	
	
