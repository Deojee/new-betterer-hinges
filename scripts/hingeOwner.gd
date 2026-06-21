extends Node3D

func _physics_process(delta: float) -> void:
	
	if !HingePlus.bodiesDict.has(self):
		return
	
	var hingeRoots = HingePlus.bodiesDict[self]
	var allHinges = []
	
	for h in hingeRoots:
		var current = h as HingePlus
		while current != null:
			allHinges.append(current)
			current = current.getNextInChain()
	
	var shuffledHinges = allHinges.duplicate()
	
	
	for i in 30:
		shuffledHinges.shuffle()
		for h in shuffledHinges:
			h.update()
	
	pass
