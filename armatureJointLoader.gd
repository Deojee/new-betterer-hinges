extends Skeleton3D

@onready var pbs = $PhysicalBoneSimulator3D
const hingePlus = preload("res://scenes/new_hinge.tscn")

# int id : PhysicalBone3D 
var idsToBones : Dictionary = {-1 : null}

enum jointType {SIDE,UP,FORWARD}

var legPattern = [
	jointType.SIDE,
	jointType.SIDE,
	jointType.UP,
	jointType.SIDE,
	jointType.UP
	]

var boneJointTypes = {}

func _ready() -> void:
	
	$PhysicalBoneSimulator3D.is_simulating_physics()
	
	var num = 0
	for bone in pbs.get_children():
		bone = bone as PhysicalBone3D
		var id = bone.get_bone_id()
		idsToBones[id] = bone
		
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_NONE
		
		#make it so it can't see itself but can see walls
		bone.set_collision_layer_value(1,true)
		bone.set_collision_layer_value(2,true)
		bone.set_collision_mask_value(3,false)
		
		bone.set_collision_mask_value(1,false)
		bone.set_collision_mask_value(2,false)
		bone.set_collision_mask_value(3,true)
		bone.set_collision_mask_value(4,true)
		
		
		
		pass
	
	
	#print(idsToBones)
	
	for id in idsToBones:
		
		if id == -1:
			continue
		
		#continue
		var bone : PhysicalBone3D = idsToBones[id]
		#var parentBone : PhysicalBone3D = idsToBones[get_bone_parent(id)]
		
		if bone.is_in_group("legTip"):
			var i = 0
			var curentBone = bone
			while curentBone and !curentBone.is_in_group("skeletonCore"):
				boneJointTypes[curentBone] = legPattern[i]
				curentBone = idsToBones[get_bone_parent(curentBone.get_bone_id())]
				i += 1
		
	
	for id in idsToBones:
		
		if id == -1:
			continue
		
		#continue
		var bone : PhysicalBone3D = idsToBones[id]
		var parentBone : PhysicalBone3D = idsToBones[get_bone_parent(id)]
		
		if !parentBone:
			parentBone = idsToBones[0]
		
		if bone.is_in_group("noHinge"):
			continue
		
		var newHinge : HingePlus = hingePlus.instantiate()
		newHinge.nodeA = parentBone
		newHinge.nodeB = bone
		
		var hingeTrans = Transform3D()
		hingeTrans.origin = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		
		var hingeGlobalTrans = parentBone.global_transform * hingeTrans
		
		#check if we have an intended joint type for this bone
		if boneJointTypes.has(bone):
			print("hello!")
			var coreToHinge = idsToBones[0].global_transform.affine_inverse() * hingeGlobalTrans
			match boneJointTypes[bone]:
				
				jointType.UP:
					var jointBasis
					var z = Vector3.UP
					var x = (coreToHinge.origin.cross(z)).normalized()
					var y = x.cross(z)
					
					hingeGlobalTrans.basis = Basis(x,y,z)
					
				jointType.SIDE:
					
					var x = (coreToHinge.origin).normalized()
					var z = x.cross(Vector3.UP).normalized()
					var y = x.cross(z)
					
					hingeGlobalTrans.basis = Basis(x,y,z)
					pass
				
			
			newHinge.transform = parentBone.global_transform.affine_inverse() * hingeGlobalTrans
			
			pass
		
		parentBone.add_child(newHinge)
		
		
		
		newHinge.setup()
		
	
	
	
	pass


func _physics_process(delta: float) -> void:
	
	if !pbs.is_simulating_physics():
		pbs.physical_bones_start_simulation()
	
	#print(pbs.is_simulating_physics())
	
	#
	pass
	
