extends Skeleton3D

@onready var pbs = $PhysicalBoneSimulator3D
const hingePlus = preload("res://scenes/new_hinge.tscn")

# int id : PhysicalBone3D 
var idsToBones : Dictionary = {}

func _ready() -> void:
	
	$PhysicalBoneSimulator3D.is_simulating_physics()
	
	var num = 0
	for bone in pbs.get_children():
		bone = bone as PhysicalBone3D
		var id = bone.get_bone_id()
		idsToBones[id] = bone
		
	
	print(idsToBones)
	
	for id in idsToBones:
		
		var bone : PhysicalBone3D = idsToBones[id]
		var parentBone : PhysicalBone3D = idsToBones[get_bone_parent(id)]
		
		var newHinge : HingePlus = hingePlus.instantiate()
		newHinge.nodeA = parentBone
		newHinge.nodeB = bone
		parentBone.add_child(newHinge)
		
		
	
	pass


func _physics_process(delta: float) -> void:
	
	#print(pbs.is_simulating_physics())
	
	pbs.physical_bones_start_simulation()
	
	
