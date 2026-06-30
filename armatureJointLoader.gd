extends Skeleton3D

@onready var pbs = $PhysicalBoneSimulator3D
const hingePlus = preload("res://scenes/new_hinge.tscn")

# int id : PhysicalBone3D 
var idsToBones : Dictionary = {-1 : null}

func _ready() -> void:
	
	$PhysicalBoneSimulator3D.is_simulating_physics()
	
	var num = 0
	for bone in pbs.get_children():
		bone = bone as PhysicalBone3D
		var id = bone.get_bone_id()
		idsToBones[id] = bone
		
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_NONE
		
		bone.set_collision_layer_value(1,true)
		bone.set_collision_layer_value(2,true)
		bone.set_collision_mask_value(3,false)
		
		bone.set_collision_mask_value(1,false)
		bone.set_collision_mask_value(2,false)
		bone.set_collision_mask_value(3,true)
		bone.set_collision_mask_value(4,true)
		
	
	#print(idsToBones)
	
	
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
		#
		
		#newHinge.position = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		#newHinge.rotation = Vector3(0,PI/2.0,0)
		#newHinge.position = get_bone_pose_position(parentBone.get_bone_id())
		
		var newHingeZ = bone.basis.z.cross(parentBone.basis.z)
		var quat = Quaternion(newHingeZ,0.0)
		newHinge.basis = Basis.IDENTITY.rotated(Vector3.UP,2.0/PI) #Basis(quat)
		
		parentBone.add_child(newHinge)
		
		
		#newHinge.position = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		#var ogDist = newHinge.global_position.distance_to(bone.global_position)
		#newHinge.position = Vector3.BACK * parentBone.get_child(0).shape.height/2.0
		#var newDist = newHinge.global_position.distance_to(bone.global_position)
		#
		#if ogDist < newDist:
			#newHinge.position = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		#
		#newHinge.look_at(bone.global_position)
		#newHinge.rotation = Vector3(0,PI/2.0,0)
		
		newHinge.setup()
		
		#prints("made hinge:" , newHinge, newHinge.nodeA,newHinge.nodeB)
		#print()
	
	
	
	pass


func _physics_process(delta: float) -> void:
	
	if !pbs.is_simulating_physics():
		pbs.physical_bones_start_simulation()
	
	#print(pbs.is_simulating_physics())
	
	#
	pass
	
