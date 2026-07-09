extends Node3D

func _physics_process(delta: float) -> void:
	
	var input = Input.get_axis("ui_up","ui_down")
	var input2 = Input.get_axis("ui_right","ui_left")
	
	$body/MlegR.position.y -= input * 0.05
	$body/MlegR.position.z -= input2 * 0.05
	
	
	if Input.is_action_just_pressed("mouseLeft"):
		var pin = $legR/segment3.get_child(4)
		pin.enabled = !pin.enabled
		
	
	
