extends Object

class_name Mathy

static func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)

static func to_global_dir(who: Node3D, vec: Vector3) -> Vector3:
	return (who.global_transform.basis * vec).normalized()

##VWC(V3.ONE,V3.RIGHT) = V3(0,1,1)
static func vec_without_component(vector : Vector3,component : Vector3):
	component = component.normalized()
	return vector - component * vector.dot(component)

static func vec_component_along(vector: Vector3, direction: Vector3) -> Vector3:
	var dir_normalized = direction.normalized()
	return dir_normalized * vector.dot(dir_normalized)

static func rotate_around_point(vec: Vector3, pivot: Vector3, axis: Vector3, angle: float) -> Vector3:
	var rot = Basis(axis.normalized(), angle)
	return rot * (vec - pivot) + pivot

static func get_signed_angle_between(v1: Vector3, v2: Vector3, axis: Vector3) -> float:
	# Ensure all vectors are normalized
	var a = v1.normalized()
	var b = v2.normalized()
	var ax = axis.normalized()

	# Compute the angle using the dot product
	var angle = acos(clamp(a.dot(b), -1.0, 1.0))  # Angle in radians

	# Compute the sign using the direction of the cross product
	var cross = a.cross(b)
	var sign = signf(ax.dot(cross))

	return angle * sign  # Signed angle in radians

# Add a debug sphere at global location.
static func draw_debug_sphere(tree : SceneTree, location, size, color := Color.RED):
	
	
	# Will usually work, but you might need to adjust this.
	var scene_root = tree.root.get_children()[0]
	# Create sphere with low detail of size.
	var sphere = SphereMesh.new()
	sphere.radial_segments = 4
	sphere.rings = 4
	sphere.radius = size
	sphere.height = size * 2
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_unshaded = true
	sphere.surface_set_material(0, material)

	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere
	scene_root.add_child(node)
	node.global_transform.origin = location
	
	var killTween = tree.create_tween().bind_node(node)
	killTween.tween_property(node,"scale",Vector3.ONE,0.02)
	killTween.tween_callback(node.queue_free)
	#node.queue_free()
	
	return node

static func draw_line_between(tree : SceneTree, location,loc2, size, color := Color.RED):
	
	var dist = (location - loc2).length()
	
	# Will usually work, but you might need to adjust this.
	var scene_root = tree.root.get_children()[0]
	# Create sphere with low detail of size.
	var sphere : CylinderMesh = CylinderMesh.new()
	sphere.radial_segments = 4
	sphere.rings = 4
	sphere.top_radius = size
	sphere.bottom_radius = size
	sphere.height = dist
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_unshaded = true
	sphere.surface_set_material(0, material)

	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = sphere
	scene_root.add_child(node)
	node.global_transform.origin = (location + loc2)/2
	
	
	
	if  !is_equal_approx(dist * 0.1,0) and !is_equal_approx( abs((location - loc2).dot(Vector3.UP)), dist): #don't rotate if it's straight up
		node.global_transform = node.global_transform.looking_at(loc2,Vector3.UP,true)
		node.rotate_object_local(Vector3.RIGHT,PI/2)
	
	
	var killTween = tree.create_tween().bind_node(node)
	killTween.tween_property(node,"scale",Vector3.ONE * 0.8,0.003)
	killTween.tween_callback(node.queue_free)
	#node.queue_free()
	
	return node

static func draw_transform(
	tree: SceneTree,
	transform: Transform3D,
	size := 1.0,
	thickness := 0.03
):
	# Origin
	draw_debug_sphere(
		tree,
		transform.origin,
		thickness * 3.0,
		Color.WHITE
	)

	var origin = transform.origin

	# Basis axes
	var x_axis = transform.basis.x.normalized() * size
	var y_axis = transform.basis.y.normalized() * size
	var z_axis = transform.basis.z.normalized() * size

	draw_line_between(
		tree,
		origin,
		origin + x_axis,
		thickness,
		Color.RED
	)

	draw_line_between(
		tree,
		origin,
		origin + y_axis,
		thickness,
		Color.GREEN
	)

	draw_line_between(
		tree,
		origin,
		origin + z_axis,
		thickness,
		Color.BLUE
	)

"""
interpolates one transform to another such that it moves only by a certain distance or rotation
"""
static func interpolateByRadsOrDist(trans1 : Transform3D,trans2 : Transform3D,maxRads,maxDist):
	
	var distance = (trans1.origin - trans2.origin).length()
	var distanceWeight = min(1.0,maxDist/distance)
	
	var angle = trans1.basis.get_rotation_quaternion().angle_to(trans2.basis.get_rotation_quaternion())
	var angleWeight = 1 if angle == 0 else min(1.0,maxRads/angle)
	
	#print(min(distanceWeight,angleWeight))
	return trans1.interpolate_with(trans2,min(distanceWeight,angleWeight))


static func printSnapped(snap := 1.0, ...args):
	for a in args:
		print(snappedf(float(a),snap))
	print("")
	pass
