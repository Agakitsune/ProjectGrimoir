extends Object
class_name Delaunay

class Triangle:
	var a: Vector2
	var b: Vector2
	var c: Vector2

	func _init(pa: Vector2, pb: Vector2, pc: Vector2):
		a = pa
		b = pb
		c = pc
		
		var d := (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
		
		if d < 0:
			var tmp := b
			b = c
			c = tmp
	
	
	func point_in_circumcircle(p) -> bool:
		var ax = self.a.x - p.x
		var ay = self.a.y - p.y
		var bx = self.b.x - p.x
		var by = self.b.y - p.y
		var cx = self.c.x - p.x
		var cy = self.c.y - p.y
		
		var det = (ax*ax + ay*ay) * (bx*cy - cx*by) \
				- (bx*bx + by*by) * (ax*cy - cx*ay) \
				+ (cx*cx + cy*cy) * (ax*by - bx*ay)
		
		return det > 0

static func triangulate(points:Array) -> Array:
	var triangles:Array = []

	# --- Super triangle ---
	var min_x = points[0].x
	var min_y = points[0].y
	var max_x = min_x
	var max_y = min_y

	for p in points:
		min_x = min(min_x, p.x)
		min_y = min(min_y, p.y)
		max_x = max(max_x, p.x)
		max_y = max(max_y, p.y)
	
	var dx = max_x - min_x
	var dy = max_y - min_y
	var delta = max(dx, dy) * 10
	
	var p1 = Vector2(min_x - delta, min_y - delta)
	var p2 = Vector2(min_x + dx*0.5, max_y + delta)
	var p3 = Vector2(max_x + delta, min_y - delta)
	
	triangles.append(Triangle.new(p1,p2,p3))
	
	# --- Insert points ---
	for point in points:
		var bad := []
		var edges := {}
		
		for tri: Triangle in triangles:
			if tri.point_in_circumcircle(point):
				bad.append(tri)
		
		for tri in bad:
			_add_edge(edges, tri.a, tri.b)
			_add_edge(edges, tri.b, tri.c)
			_add_edge(edges, tri.c, tri.a)
		
		for tri in bad:
			triangles.erase(tri)
		
		for key in edges:
			var edge = edges[key]
			triangles.append(Triangle.new(edge[0], edge[1], point))

	triangles = triangles.filter(func(t):
		return (t.a != p1 and t.b != p1 and t.c != p1
		and t.a != p2 and t.b != p2 and t.c != p2
		and t.a != p3 and t.b != p3 and t.c != p3)
	)
	
	var indices: PackedInt32Array
	
	for tri in triangles:
		for i in range(points.size()):
			if tri.a == points[i]:
				indices.append(i)
			elif tri.b == points[i]:
				indices.append(i)
			elif tri.c == points[i]:
				indices.append(i)
	
	return indices


static func _add_edge(edges:Dictionary, a:Vector2, b:Vector2):

	var key = str(a) + "|" + str(b)
	var reverse = str(b) + "|" + str(a)

	if edges.has(reverse):
		edges.erase(reverse)
	else:
		edges[key] = [a,b]


#static func triangulate(
	#s: PackedVector2Array
#) -> PackedInt32Array:
	#var triangles: Array[Triangle]
	#
	#var p1 := Vector2(-100000.0, -100000.0)
	#var p2 := Vector2(100000.0, -100000.0)
	#var p3 := Vector2(0.0, 100000.0)
	#
	#var super_tri := Triangle.new(
		#p1, p2, p3
	#)
	#
	#triangles.append(super_tri)
	#
	#for p in s:
		#var bad_triangles = []
		#var polygon = []
		#
		#for tri in triangles:
			#if tri.point_in_circumcircle(p):
				#bad_triangles.append(tri)
#
		#for tri in bad_triangles:
			#var edges = [
				#[tri.a, tri.b],
				#[tri.b, tri.c],
				#[tri.c, tri.a]
			#]
#
			#for edge in edges:
#
				#var shared = false
#
				#for other in bad_triangles:
					#if other == tri:
						#continue
#
					#var other_edges = [
						#[other.a, other.b],
						#[other.b, other.c],
						#[other.c, other.a]
					#]
#
					#for oe in other_edges:
						#if edge[0] == oe[1] and edge[1] == oe[0]:
							#shared = true
#
				#if not shared:
					#polygon.append(edge)
#
		#for tri in bad_triangles:
			#triangles.erase(tri)
#
		#for edge in polygon:
			#triangles.append(Triangle.new(edge[0], edge[1], p))
	#
	#triangles = triangles.filter(
		#func(t):
		#return (t.a != p1 and t.b != p1 and t.c != p1
			#and t.a != p2 and t.b != p2 and t.c != p2
			#and t.a != p3 and t.b != p3 and t.c != p3)
	#)
	#
	#var indices: PackedInt32Array
	#
	#for tri in triangles:
		#for i in range(s.size()):
			#if tri.a == s[i]:
				#indices.append(i)
			#elif tri.b == s[i]:
				#indices.append(i)
			#elif tri.c == s[i]:
				#indices.append(i)
	#
	#return indices
