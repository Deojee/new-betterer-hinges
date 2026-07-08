extends Node3D

@export var hingeOwner : HingeOwner
@export var startingHinge : HingePlus
@export var endPointMarker : Marker3D

@export var target : Node3D

func _physics_process(delta: float) -> void:
	
	var chain = []
	var current = startingHinge
	while current:
		chain.append(current)
		current = current.getNextInChain()
	
	for hinge in chain:
		hinge = hinge as HingePlus
		var hingeToEndpoint = hinge.global_transform.affine_inverse() * endPointMarker.global_transform
		var hingeToTarget = hinge.global_transform.affine_inverse() * target.global_transform
		
		var rotAx = hinge.rotAxis
		
		hingeToEndpoint.origin -= hingeToEndpoint.origin.dot(rotAx) * rotAx
		hingeToTarget.origin -= hingeToTarget.origin.dot(rotAx) * rotAx
		
		hinge.targetAngle = (hinge.targetAngle + 
			angleDifferenceAroundAxis(
				rotAx,
				hingeToEndpoint.origin,
				hingeToTarget.origin)
			)
		
		prints(hinge,rad_to_deg(hinge.targetAngle))
		
		pass
	
	pass


"""
takes two vectors and removes their components around axis

returns the angle from A to B, positive meaning clockwise from the perspecive of a camera located 1 unit along the rot axis
"""
func angleDifferenceAroundAxis(axis : Vector3,vecA : Vector3,vecB : Vector3):
	
	vecA -= vecA.dot(axis) * axis
	vecB -= vecB.dot(axis) * axis
	
	if is_zero_approx(vecA.length()) or is_zero_approx(vecB.length()):
		return 0
	
	var angle = vecA.angle_to(vecB)
	
	var thirdVec = vecA.cross(axis)
	var sign = sign(thirdVec.dot(vecB))
	
	return angle * sign
	
	pass
