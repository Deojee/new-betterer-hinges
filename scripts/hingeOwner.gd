extends Node3D

func _physics_process(delta: float) -> void:
	
	if !HingePlus.bodiesDict.has(self):
		return
	
	var hingeRoots = HingePlus.bodiesDict[self]
	var allHinges = []
	
	for h in hingeRoots:
		var current = h as HingePlus
		while current != null:
			
			#current.enableMotor = false
			#current.aimForTarget = false
			
			allHinges.append(current)
			current = current.getNextInChain()
			
			
			
	
	var shuffledHinges = allHinges.duplicate()
	
	var iterations = 20
	var inv = 1 # 1.0/iterations * 0.001
	
	#print(shuffledHinges.size())
	for i in iterations:
		shuffledHinges.shuffle()
		for h in shuffledHinges:
			h.update(inv)
			
	
	pass
