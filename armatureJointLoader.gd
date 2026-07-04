@tool
extends Skeleton3D

@onready var pbs = $PhysicalBoneSimulator3D
const hingePlus = preload("res://scenes/new_hinge.tscn")

@export var rbp : Node3D

# int id : PhysicalBone3D 
var idsToBones : Dictionary = {-1 : null}

var bonesToRigidBodies : Dictionary

var hingeOwnerScript = preload("res://scripts/hingeOwner.gd")

enum jointType {SIDE,UP,FORWARD}

var legPattern = [
	jointType.SIDE,
	jointType.SIDE,
	jointType.UP,
	jointType.SIDE,
	jointType.UP
	]

var boneJointTypes = {}
var bonesToParents = {}

func _ready() -> void:
	pass
	

var setupNow = false:
	get:
		return false
	set(value):
		print("setup start")
		setup()
		print("setup done!")

func setup():
	$PhysicalBoneSimulator3D.is_simulating_physics()
	
	for child in rbp.get_children():
		child.queue_free()
	
	var num = 0
	for bone in pbs.get_children():
		bone = bone as PhysicalBone3D
		var id = bone.get_bone_id()
		idsToBones[id] = bone
		
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_NONE
		
		var rigidBody = RigidBody3D.new()
		
		rbp.add_child(rigidBody)
		editorAddChild(rigidBody,rbp,bone.name + " rb")
		
		#rigidBody.global_transform = get_bone_global_rest(id)
		#bone.global_transform
		
		
		for child in bone.get_children():
			#child.reparent(rigidBody,true)
			
			var duplicate = child.duplicate()
			editorAddChild(duplicate,rigidBody,"collision shape")
			#child.queue_free()
		
		bonesToRigidBodies[bone] = rigidBody
		bone.set_collision_mask_value(1, false)
		bone.set_collision_layer_value(1, false)
		rigidBody.set_collision_layer_value(1, false)
	
	#print(idsToBones)
	
	var spineRb : RigidBody3D = bonesToRigidBodies[idsToBones[0]]
	spineRb.set_script(hingeOwnerScript)
	
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
				bonesToParents[curentBone] = idsToBones[get_bone_parent(curentBone.get_bone_id())]
				curentBone = bonesToParents[curentBone]
				
				i += 1
	
	#
	
	for id in idsToBones.keys():
		
		if id == -1: # or id > 20:
			continue
		
		#continue
		var bone : PhysicalBone3D = idsToBones[id]
		var parentBone : PhysicalBone3D = idsToBones[get_bone_parent(id)]
		
		
		
		if !parentBone:
			parentBone = idsToBones[0]
		
		if bone.is_in_group("noHinge"):
			continue
		
		var rb = bonesToRigidBodies[bone]
		var prb = bonesToRigidBodies[parentBone]
		
		var newHinge : HingePlus = hingePlus.instantiate()
		newHinge.nodeA = prb
		newHinge.nodeB = rb
		#newHinge.rotation = Vector3(0,PI/2.0,0)
		
		
		prb.add_child(newHinge)
		editorAddChild(newHinge,prb,prb.name + " hinge")
		
		newHinge.position = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		var ogDist = newHinge.global_position.distance_to(bone.global_position)
		newHinge.position = Vector3.BACK * parentBone.get_child(0).shape.height/2.0
		var newDist = newHinge.global_position.distance_to(bone.global_position)
		
		if ogDist < newDist:
			newHinge.position = Vector3.FORWARD * parentBone.get_child(0).shape.height/2.0
		
		newHinge.look_at(bone.global_position)
		newHinge.rotate_y(PI/2.0)
		
		newHinge.setup()
		
		#newHinge.aimForTarget = false
		#newHinge.enableMotor = false
		
		#prints("made hinge:" , newHinge, newHinge.nodeA,newHinge.nodeB)
		#print()
	
	
	
	pass

func editorAddChild(childNode : Node,newParent : Node,newName : StringName):
	childNode.set_name(newName)
	newParent.add_child(childNode)
	childNode.owner = get_tree().edited_scene_root


func _physics_process(delta: float) -> void:
	
	if !pbs.is_simulating_physics():
		pbs.physical_bones_start_simulation()
	
	for key in bonesToRigidBodies.keys():
		var rb : RigidBody3D = bonesToRigidBodies[key]
		var b : PhysicalBone3D = key
		
		b.angular_velocity = rb.angular_velocity
		b.linear_velocity = rb.linear_velocity
		b.global_transform = rb.global_transform
		
	
	pass
	
