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
	
	var iterations = 10
	var inv = 0.1 # 1.0/iterations * 0.001
	
	print(shuffledHinges.size())
	for i in iterations:
		shuffledHinges.shuffle()
		for h in shuffledHinges:
			h.update(inv)
			
	
	pass
