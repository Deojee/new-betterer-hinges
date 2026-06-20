extends Node3D

@export var boxScene : PackedScene
func _ready() -> void:
	
	
	return
	seed(int("abc"))
	var spawnCubeWidth = 8
	
	for i in randi_range(80,100):
		var newBox = boxScene.instantiate()
		newBox.position = Vector3(
			randf_range(-spawnCubeWidth,spawnCubeWidth),
			spawnCubeWidth + 2 + randf_range(-spawnCubeWidth,spawnCubeWidth),
			randf_range(-spawnCubeWidth,spawnCubeWidth)
		)
		
		add_child(newBox)
		
	
	
	
	pass
