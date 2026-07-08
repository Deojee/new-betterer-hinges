extends Node3D

class_name MP

##short for node, short for instance
static var INSTANCE : MP

"""
basically an object pool that just pools meshspheres and their colors
"""

var unusedPool = []

var usedPool = []

var sphereToPlaceTime : Dictionary = {}

func _ready() -> void:
	INSTANCE = self

func _physics_process(delta: float) -> void:
	
	#unload all the spheres that are old
	var frame = Engine.get_physics_frames()
	for sphere in usedPool:
		if !sphereToPlaceTime.has(sphere):
			unload(sphere)
		else:
			if sphereToPlaceTime[sphere] != frame:
				unload(sphere)
		
	
	pass

#marks, for one frame, a location with a sphere of size and color
static func mark(location : Vector3,size := 1.0,color := Color.RED):
	
	INSTANCE._mark(location,size,color)
	

func _mark(location : Vector3,size := 1.0,color := Color.RED):
	
	if unusedPool.size() > 0:
		usedPool.append(unusedPool.pop_back())
	else:
		var newSphere = MeshInstance3D.new()
		newSphere.mesh = SphereMesh.new()
		add_child(newSphere)
		usedPool.append(newSphere)
	
	var marker : MeshInstance3D = usedPool.back()
	
	marker.global_position = location
	marker.scale = Vector3.ONE * size
	marker.material_override = getMatOfColor(color)
	
	sphereToPlaceTime[marker] = Engine.get_physics_frames()
	

var materialDict : Dictionary = {}
func getMatOfColor(color : Color):
	if materialDict.has(color):
		return materialDict[color]
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_unshaded = true
	
	materialDict[color] = material
	
	return material

func unload(sphere : Node3D):
	if sphereToPlaceTime.has(sphere):
		sphereToPlaceTime.erase(sphere)
	sphere.visible = false
	sphere.global_position = global_position
