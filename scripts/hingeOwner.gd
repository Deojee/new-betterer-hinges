extends Node3D

var allHinges = []
var needsToRecountHinges = true

func _physics_process(delta: float) -> void:
	
	if !HingePlus.bodiesDict.has(self):
		return
	
	
	
	
	
	if allHinges.is_empty() or needsToRecountHinges:
		needsToRecountHinges = false
		
		var hingeRoots  = HingePlus.bodiesDict[self]
		allHinges.append_array(hingeRoots)
		
		var count = 0
		#hinges before index count in allHinges have been check for children
		while allHinges.size() > count:
			
			var newHinges = allHinges[count].getAllNextInChain()
			
			for hinge in newHinges:
				if allHinges.has(hinge):
					continue
				else:
					allHinges.append(hinge)
			
			count += 1
		
		var completed = 0
		var j = 0
		
		var nodesThatShouldBeCompleted = []
		
		while completed < allHinges.size():
			j = completed + 1 #only need to add exceptions with unprocessed hinges
			while j < allHinges.size():
				allHinges[completed].nodeA.add_collision_exception_with(allHinges[j].nodeA)
				print(allHinges[completed].name + str(allHinges[completed].nodeA.get_collision_exceptions().size()) + " " + allHinges[j].name)
				j += 1
			print()
			
			
			completed += 1
		
		print()
		for hinge in allHinges:
			print(hinge.nodeA.get_collision_exceptions().size())
			print(hinge.nodeB.get_collision_exceptions().size())
		
	
	
	var shuffledHinges = allHinges.duplicate()
	
	var iterations = 5
	var inv = 1.0 # 1.0/iterations * 0.001
	
	#print(shuffledHinges.size())
	for i in iterations:
		shuffledHinges.shuffle()
		for h in shuffledHinges:
			h.update(inv)
			
	
	pass
