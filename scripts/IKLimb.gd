extends Node3D

@export var hingeOwner : HingeOwner
@export var startingHinge : HingePlus
@export var endPointMarker : Marker3D

@export var target : Node3D


var lastHinge = null
func _physics_process(delta: float) -> void:
	
	#$testingGuy.global_transform = $testingGuy.global_transform.rotated_local(Vector3.FORWARD,0.02)
	
	if Input.is_action_pressed("mouseLeft"):
		return
	
	var chain : Array[HingePlus] = []
	
	var current = startingHinge
	while current:
		chain.append(current)
		current = current.getNextInChain()
	
	var i = 0
	while i < chain.size():
		
		var hinge : HingePlus = chain[i]
		
		var realTransform = hinge.global_transform
		
		var futureTransform = forwardKinematics(chain,endPointMarker)
		
		
		hinge = hinge as HingePlus
		
		var hingePos = futureTransform[i].origin
		var futureEndPointPos = futureTransform.back().origin
		
		var hingeToEndpoint = futureEndPointPos - hingePos
		var hingeToTarget = target.global_position - hingePos
		
		lastHinge = hinge
		var angle = angleDifferenceAroundAxis(
					futureTransform[i].basis.z,
					hingeToTarget,
					hingeToEndpoint
					)
		
		hinge.targetAngle = (
			fmod(
				hinge.targetAngle + 
				angle
				,
				TAU
				)
			)
		
		#prints(hinge,rad_to_deg(hinge.targetAngle),rad_to_deg(angle))
		
		i += 1
	
	forwardKinematics(chain,endPointMarker)
	
	pass

func forwardKinematics(chain : Array[HingePlus],endPoint : Node3D) -> Array[Transform3D]:
	
	var currentNode : HingePlus = chain[0]
	var currentTrans : Transform3D = chain[0].global_transform
	
	var targetPoses : Array[Transform3D] = []
	targetPoses.resize(chain.size() + 1)
	
	#keeps track of the differences between each hinge. local space
	var hingeToNextTransforms : Array[Transform3D] = []
	
	var i : int = 0
	hingeToNextTransforms.resize(chain.size())
	while i < chain.size():
		
		#it's endpoint unless there's an actual next link in the chain
		
		var nextTrans : Transform3D = endPoint.global_transform
		if i + 1 != chain.size():
			nextTrans = chain[i+1].global_transform
		
		hingeToNextTransforms[i] = chain[i].global_transform.affine_inverse() * nextTrans
		
		#hingeToNextTransforms[i] = hingeToNextTransforms[i].rotated_local(
			#Vector3.FORWARD,
			##-chain[i].getAngleToTargetAngle()
			#-PI/2.0
			#)
		
		hingeToNextTransforms[i] = hingeToNextTransforms[i].rotated(
			Vector3.FORWARD,
			chain[i].getAngleToTargetAngle()
			)
		
		#print(rad_to_deg(chain[i].getAngleToTargetAngle()))
		
		i += 1
	#print()
	
	i = 0
	while i < chain.size() + 1:
		
		targetPoses[i] = currentTrans
		
		MP.mark(
			currentTrans.origin,
			3.0,
			Color.GREEN.lerp(
				Color.RED,
				float(i)/float(chain.size()
				)
			)
		)
		
		if i < chain.size():
			currentTrans = currentTrans * hingeToNextTransforms[i]
		
		i += 1
	
	return targetPoses
	
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
	
