extends Node3D

@export var hingeOwner : HingeOwner
@export var startingHinge : HingePlus
@export var endPointMarker : Marker3D

@export var target : Node3D


var lastHinge = null
func _physics_process(delta: float) -> void:
	
	var chain : Array[HingePlus] = []
	
	var current = startingHinge
	while current:
		chain.append(current)
		current = current.getNextInChain()
	
	var i = 0
	while i < chain.size():
		
		var hinge : HingePlus = chain[i]
		
		var realTransform = hinge.global_transform
		
		
		
		hinge = hinge as HingePlus
		
		
		
		var hingeToEndpoint = endPointMarker.global_position - hinge.global_position
		var hingeToTarget = target.global_position - hinge.global_position
		
		lastHinge = hinge
		var angle = angleDifferenceAroundAxis(
					hinge.rotAxis,
					hingeToTarget,
					hingeToEndpoint
					)
		
		hinge.targetAngle = (
			fmod(
				hinge.getAngle() + 
				angle
				,
				TAU
				)
			)
		
		#prints(hinge,rad_to_deg(hinge.targetAngle),rad_to_deg(angle))
		
		i += 1
	
	forwardKinematics(chain)
	
	pass

func forwardKinematics(chain : Array[HingePlus]):
	
	var currentNode : HingePlus = chain[0]
	var currentTrans : Transform3D = chain[0].global_transform
	
	var targetPoses = []
	
	
	pass


"""
takes two vectors and removes their components around axis

returns the angle from A to B, positive meaning clockwise from the perspecive of a camera located 1 unit along the rot axis
"""
func angleDifferenceAroundAxis(axis : Vector3,vecA : Vector3,vecB : Vector3):
	
	#Mathy.draw_debug_sphere(get_tree(),vecA + lastHinge.global_position,1.0,Color.GREEN)
	#Mathy.draw_debug_sphere(get_tree(),vecB + lastHinge.global_position,1.0,Color.RED)
	#MP.mark(vecA + lastHinge.global_position,2.0,Color.GREEN)
	#MP.mark(vecB + lastHinge.global_position,1.0,Color.RED)
	
	vecA -= vecA.dot(axis) * axis
	vecB -= vecB.dot(axis) * axis
	
	#MP.mark(vecA + lastHinge.global_position,1.0,Color.REBECCA_PURPLE)
	#MP.mark(vecB + lastHinge.global_position,1.0,Color.MEDIUM_PURPLE)
	
	
	if is_zero_approx(vecA.length()) or is_zero_approx(vecB.length()):
		return 0
	
	var angle = vecA.angle_to(vecB)
	
	var thirdVec = vecA.cross(axis)
	var sign = sign(thirdVec.dot(vecB))
	
	return -angle * sign
	
	pass
