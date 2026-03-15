extends Object
class_name Castlevania

# Inspired by this wonderful article (like go read this shit it's so good)
# https://www.gamedeveloper.com/programming/procedural-dungeon-generation-algorithm

const TILESET := preload("uid://c1k3oxffmy2kj")
const SCRIPT := preload("uid://jgoxxbss7bm5")

var _spawn: GraphCell

var _cell: Array[GraphCell]
var _main_graph: Array[GraphCell]
var _sub_graph: Array[GraphCell]

var _monster_spawns: PackedVector2Array

func generate() -> Array[TileMapLayer]:
	# Add Spawn room:
	_spawn = GraphCell.new()
	_spawn.rect = Rect2(
		Vector2(-16.0, -16.0),
		Vector2(32.0, 32.0)
	)
	_spawn.pos = _spawn.rect.get_center()
	_spawn.grade = 0
	_spawn.freeze = true
	
	_cell.append(_spawn)
	
	for i in range(randi_range(8, 12)):
		var s := randi_range(8, 12)
		var size := Vector2(
			s,
			s
		) * 4.0
		var pos := (get_random_point(2.0, 4.0) * 4.0).snappedf(4.0)
		
		var rect := Rect2(pos - size / 2, size)
		
		var cell := GraphCell.new()
		cell.rect = rect
		cell.pos = rect.get_center()
		
		cell.grade = 0
		
		_cell.append(cell)
	
	for i in range(60):
		var s := randi_range(2, 8)
		var size := Vector2(
			s,
			s
		) * 4.0
		var pos := (get_random_point(6.0, 14.0) * 4.0).snappedf(4.0)
		
		var rect := Rect2(pos - size / 2, size)
		
		var cell := GraphCell.new()
		cell.rect = rect
		cell.pos = rect.get_center()
		
		if size.x >= 24.0 and size.y >= 24.0:
			cell.grade = 1
		else:
			cell.grade = 2
		
		_cell.append(cell)
	
	# Separation steering behavior
	separate()
	
	# Debug
	var info := {
		0: 0,
		1: 0,
		2: 0
	}
	
	for c in _cell:
		info[c.grade] += 1
	
	## Push back main and sub graph
	generate_graph()
	
	# Prim's algorithm
	prims(_main_graph, 0)
	prims(_sub_graph, 1)
	
	# Estimate depth
	calculate_depth()
	
	# Generate loops
	generate_loops()
	
	# Generate hallways
	generate_hallways()
	
	# Generate tilemap layers
	var maps := generate_maps()
	
	# Populate monsters
	for c in _main_graph:
		if c == _spawn:
			continue
		var k := randi_range(2, 4)
		var cen := c.rect.get_center()
		var rad := minf(c.rect.size.x, c.rect.size.y)
		
		for i in range(k):
			var p := cen + get_random_point(2.0, rad - 1.0)
			var s := Vector2i(p) / 4
			
			if s not in maps[1].get_used_cells_by_id(5):
				_monster_spawns.push_back(s * 32)
	
	return maps


func generate_maps() -> Array[TileMapLayer]:
	var ground := TileMapLayer.new()
	var wall := TileMapLayer.new()
	var underlay := TileMapLayer.new()
	var overlay := TileMapLayer.new()
	var wall_overlay := TileMapLayer.new()
	
	ground.tile_set = TILESET
	wall.tile_set = TILESET
	underlay.tile_set = TILESET
	overlay.tile_set = TILESET
	wall_overlay.tile_set = TILESET
	
	ground.set_script(SCRIPT)
	ground._wall = wall
	ground._hazard = underlay
	
	var visited: Array[GraphCell]
	var current: Array[GraphCell] = [_spawn]
	var next: Array[GraphCell]
	
	while not current.is_empty():
		next = []
		for c in current:
			for l in c.links:
				if l.to.grade > 0:
					continue
				
				place_room(c.rect, ground)
				c.visible = true
				
				if not l.disabled:
					place_link(l, ground)
					
					if l.to not in visited:
						next.append(l.to)
		
		visited.append_array(current)
		current = next
	
	var zone := ground.get_used_rect().grow(10)
	
	var walls: Array[Vector2i]
	var down: Array[Vector2i]
	
	for x in range(zone.size.x):
		for y in range(zone.size.y):
			var c := Vector2i(x, y)
			if ground.get_cell_source_id(zone.position + c) == -1:
				if ground.get_cell_source_id(zone.position + c + Vector2i.DOWN) != -1:
					down.push_back(zone.position + c)
					down.push_back(zone.position + c + Vector2i.UP)
					c += Vector2i.UP * 2
				elif ground.get_cell_source_id(zone.position + c + Vector2i.DOWN * 2) != -1:
					c += Vector2i.UP * 2
				walls.push_back(zone.position + c)
	
	wall.set_cells_terrain_connect(
		walls, 0, 0
	)
	
	wall.set_cells_terrain_connect(
		down, 1, 0
	)
	
	for p in down:
		ground.set_cell(
			p, 0, select_floor_tile()
		)
	
	place_detail(ground)
	
	var carpet: Array[Vector2i]
	for x in range(4):
		for y in range(4):
			var c := Vector2i(x, y)
			carpet.push_back(Vector2i(-2, -2) + c)
	underlay.set_cells_terrain_connect(
		carpet, 0, 1
	)
	
	for c in _cell:
		if c.visible and c != _spawn:
			place_deco(c.rect, underlay)
			place_hazard(c.rect, underlay)
	
	for c in _main_graph:
		place_candles(c.rect, overlay, underlay)
	
	for p in ground.get_used_cells():
		if randf() >= 0.9:
			if underlay.get_cell_source_id(p) == -1:
				underlay.set_cell(
					p, 7, Vector2i(randi_range(0, 5), 2)
				)
	
	for p in wall.get_used_cells_by_id(2):
		var from := wall.get_cell_atlas_coords(p)
		if from.y == 1:
			if randf() >= 0.5:
				match randi_range(0, 1):
					0: wall_overlay.set_cell(p, 7, Vector2i(randi_range(0, 6), 0))
					1: wall_overlay.set_cell(p, 3, Vector2i(0, 8))
	
	return [
		ground,
		underlay,
		overlay,
		wall,
		wall_overlay,
	]


func select_floor_tile() -> Vector2i:
	return Vector2i(
		0,
		0
	)


func place_deco(r: Rect2, h: TileMapLayer):
	var start := Vector2i(r.position) / 4
	var size := Vector2i(r.size) / 4
	
	if size.x < 3 or size.y < 3:
		return
	
	if randf() >= 0.125:
		var s := Vector2i(
			randi_range(2, mini(size.x - 1, 5)),
			randi_range(2, mini(size.y - 1, 5))
		)
		
		var p := Vector2i(
			randi_range(1, size.x - s.x - 1),
			randi_range(1, size.y - s.y - 1)
		)
		
		var hazard: Array[Vector2i]
		for x in range(s.x):
			for y in range(s.y):
				var c := Vector2i(x, y)
				hazard.push_back(start + p + c)
		
		var k := [1, 2, 4].pick_random() as int
		
		h.set_cells_terrain_connect(
			hazard, 0, k
		)


func place_hazard(r: Rect2, h: TileMapLayer):
	var start := Vector2i(r.position) / 4
	var size := Vector2i(r.size) / 4
	
	if size.x < 3 or size.y < 3:
		return
	
	if randf() >= 0.5:
		var s := Vector2i(
			randi_range(2, size.x - 2),
			randi_range(2, size.y - 2)
		)
		
		var p := Vector2i(
			randi_range(1, size.x - s.x - 1),
			randi_range(1, size.y - s.y - 1)
		)
		
		var hazard: Array[Vector2i]
		for x in range(s.x):
			for y in range(s.y):
				var c := Vector2i(x, y)
				if h.get_cell_source_id(start + p + c) != -1:
					hazard.push_back(start + p + c)
		
		h.set_cells_terrain_connect(
			hazard, 0, 3
		)


func place_detail(g: TileMapLayer):
	g.set_cells_terrain_connect(
		g.get_used_cells(),
		2,
		0
	)


func place_candles(r: Rect2, l: TileMapLayer, h: TileMapLayer):
	var start := Vector2i(r.position) / 4
	var end := Vector2i(r.end) / 4
	var a := Vector2i(start.x, end.y)
	var b := Vector2i(end.x, start.y)
	
	if randf() >= 0.6:
		_place_candles(start + Vector2i(1, 1), l, h)
	if randf() >= 0.6:
		_place_candles(end + Vector2i(-2, -2), l ,h)
	if randf() >= 0.6:
		_place_candles(a + Vector2i(1, -2), l, h)
	if randf() >= 0.6:
		_place_candles(b + Vector2i(-2, 1), l, h)


func _place_candles(p: Vector2i, l: TileMapLayer, h: TileMapLayer):
	for x in range(-1, 2):
		for y in range(-1, 2):
			if randf() >= 0.8:
				var c := Vector2i(x, y)
				if h.get_cell_source_id(p + c) != -1:
					continue
				
				var t := randf() > 0.8
				
				if t:
					l.set_cell(
						p + c, 7, Vector2i(randi_range(1, 3), 3)
					)
				else:
					l.set_cell(
						p + c, 3, Vector2i(0, randi_range(9, 11))
					)


func place_room(r: Rect2, l: TileMapLayer):
	var start := Vector2i(r.position) / 4
	var s := Vector2i(r.size) / 4
	
	for x in range(s.x):
		for y in range(s.y):
			var coord := select_floor_tile()
			
			l.set_cell(
				start + Vector2i(x, y), 0, coord
			)


func overlap_with_room(p: Vector2i, l: TileMapLayer):
	#if l.get_cell_source_id(p) == -1:
	for c in _cell:
		if c.grade > 0:
			#var r := Rect2i(c.rect)
			if c.rect.has_point(p * 4):
				place_room(c.rect, l)
				c.visible = true


func place_link(link: GraphLink, l: TileMapLayer):
	var start := Vector2i(link.start_door.position(link.from.rect)) / 4
	var end := Vector2i(link.end_door.position(link.to.rect)) / 4
	var c: Vector2i
	
	place_path(start, l)
	place_path(end, l)
	
	if link.start_door.straight(link.end_door):
		var diff := (end - start).abs()
		
		match link.start_door.dir:
			Door.Direction.North:
				for i in range(diff.y):
					place_path(end + Vector2i(0, i), l)
			Door.Direction.East:
				for i in range(diff.x):
					place_path(start + Vector2i(i, 0), l)
			Door.Direction.South:
				for i in range(diff.y):
					place_path(start + Vector2i(0, i), l)
			Door.Direction.West:
				for i in range(diff.x):
					place_path(end + Vector2i(i, 0), l)
	else:
		var mid := start
		var a := int(link.start_door.dir) % 2
		
		if a == 0:
			mid.y = end.y
		else:
			mid.x = end.x
		
		var diff_a := (mid - start).abs()
		var diff_b := (end - mid).abs()
		
		match link.start_door.dir:
			Door.Direction.North:
				for i in range(diff_a.y):
					place_path(mid + Vector2i(0, i), l)
			Door.Direction.East:
				for i in range(diff_a.x):
					place_path(start + Vector2i(i, 0), l)
			Door.Direction.South:
				for i in range(diff_a.y):
					place_path(start + Vector2i(0, i), l)
			Door.Direction.West:
				for i in range(diff_a.x):
					place_path(mid + Vector2i(i, 0), l)
		
		match link.end_door.dir:
			Door.Direction.North:
				for i in range(diff_b.y):
					place_path(mid + Vector2i(0, i), l)
			Door.Direction.East:
				for i in range(diff_b.x):
					place_path(end + Vector2i(i, 0), l)
			Door.Direction.South:
				for i in range(diff_b.y):
					place_path(end + Vector2i(0, i), l)
			Door.Direction.West:
				for i in range(diff_b.x):
					place_path(mid + Vector2i(i, 0), l)


func place_path(p: Vector2i, l: TileMapLayer):
	overlap_with_room(p, l)
	
	for x in range(-1, 1):
		for y in range(-1, 1):
			var coord := select_floor_tile()
			l.set_cell(
				p + Vector2i(x, y), 0, coord
			)


func separate():
	var overlap := true
	
	while overlap:
		overlap = false
		for i in range(_cell.size()):
			for j in range(_cell.size()):
				if i == j:
					continue
				
				if _cell[i].rect.intersects(_cell[j].rect):
					overlap = true
					var force := _cell[i].rect.get_center().direction_to(_cell[j].rect.get_center()) * 4.0
					
					if not _cell[i].freeze:
						_cell[i].rect.position -= force
						_cell[i].rect.position = _cell[i].rect.position.snappedf(4.0)
					
					if not _cell[j].freeze:
						_cell[j].rect.position += force
						_cell[j].rect.position = _cell[j].rect.position.snappedf(4.0)


func generate_graph():
	var points: PackedVector2Array
	var sub: PackedVector2Array
	for c in _cell:
		c.pos = c.rect.get_center()
		match c.grade:
			0:
				points.append(c.pos)
				_main_graph.append(c)
				sub.append(c.pos)
				_sub_graph.append(c)
			1:
				sub.append(c.pos)
				_sub_graph.append(c)
	
	var main_delaunay := Geometry2D.triangulate_delaunay(points)
	var sub_delaunay := Geometry2D.triangulate_delaunay(sub)
	
	for i in range(sub_delaunay.size() / 3):
		var a := _sub_graph[sub_delaunay[i * 3]]
		var b := _sub_graph[sub_delaunay[i * 3 + 1]]
		var c := _sub_graph[sub_delaunay[i * 3 + 2]]
		
		a.link_with(b)
		b.link_with(a)
		a.link_with(c)
		c.link_with(a)
		b.link_with(c)
		c.link_with(b)
	
	for i in range(main_delaunay.size() / 3):
		var a := _main_graph[main_delaunay[i * 3]]
		var b := _main_graph[main_delaunay[i * 3 + 1]]
		var c := _main_graph[main_delaunay[i * 3 + 2]]
		
		a.link_with(b)
		b.link_with(a)
		a.link_with(c)
		c.link_with(a)
		b.link_with(c)
		c.link_with(b)


func calculate_depth():
	var depth := 0
	var visited: Array[GraphCell]
	var current: Array[GraphCell] = [_spawn]
	var next: Array[GraphCell]
	
	while not current.is_empty():
		next = []
		for c in current:
			c.depth = depth
			for l in c.links:
				if l.to.grade > 0:
					continue
				if not l.disabled and l.to not in visited:
					next.append(l.to)
		depth += 1
		
		visited.append_array(current)
		current = next


func generate_loops():
	var k := randi_range(3, 5)
	while k > 0:
		var cell: GraphCell
		
		cell = _main_graph.pick_random() as GraphCell
		if cell.depth == 0: # Cannot pick start
			continue
		
		var max_cost := 0
		var link: GraphLink = null
		for l in cell.links:
			if l.disabled:
				var diff := absi(cell.depth - l.to.depth)
				if diff > max_cost:
					link = l
		
		if link == null:
			continue
		
		link.disabled = false
		k -= 1


func generate_hallways():
	var links: Array[GraphLink]
	var visited: Array[GraphCell]
	var current: Array[GraphCell] = [_spawn]
	var next: Array[GraphCell]
	
	while not current.is_empty():
		next = []
		for c in current:
			for l in c.links:
				if l.to.grade > 0:
					continue
				if not l.disabled:
					links.append(l)
					if l.to not in visited:
						next.append(l.to)
		
		visited.append_array(current)
		current = next
	
	for l in links:
		var from := l.from
		var to := l.to
		
		var bound := from.rect.merge(to.rect)
		
		var start := from.rect.position.max(to.rect.position)
		var end := from.rect.end.min(to.rect.end)
		var mid := (start + end) / 2.0
		
		if start.x < end.x: # Overlap
			l.start_door = Door.new()
			l.end_door = Door.new()
			
			l.start_door.offset = mid.x - from.rect.position.x
			l.end_door.offset = mid.x - to.rect.position.x
			
			if from.rect.position.y < to.rect.position.y:
				l.start_door.dir = Door.Direction.South
				l.end_door.dir = Door.Direction.North
			else:
				l.start_door.dir = Door.Direction.North
				l.end_door.dir = Door.Direction.South
		elif start.y < end.y: # Overlap
			l.start_door = Door.new()
			l.end_door = Door.new()
			
			l.start_door.offset = mid.y - from.rect.position.y
			l.end_door.offset = mid.y - to.rect.position.y
			
			if from.rect.position.x < to.rect.position.x:
				l.start_door.dir = Door.Direction.East
				l.end_door.dir = Door.Direction.West
			else:
				l.start_door.dir = Door.Direction.West
				l.end_door.dir = Door.Direction.East
		else:
			l.start_door = Door.new()
			l.end_door = Door.new()
			
			var a := from.rect
			var b := to.rect
			
			var gap_x = maxf(
				b.position.x - (a.position.x + a.size.x),
				a.position.x - (b.position.x + b.size.x)
			)
			
			var gap_y = maxf(
				b.position.y - (a.position.y + a.size.y),
				a.position.y - (b.position.y + b.size.y)
			)
			
			if gap_x > gap_y:
				l.start_door.offset = a.size.y / 2.0
				l.end_door.offset = b.size.x / 2.0
				
				if a.position.x < b.position.x:
					l.start_door.dir = Door.Direction.East
				else:
					l.start_door.dir = Door.Direction.West
				
				if a.position.y < b.position.y:
					l.end_door.dir = Door.Direction.North
				else:
					l.end_door.dir = Door.Direction.South
			else:
				l.start_door.offset = a.size.x / 2.0
				l.end_door.offset = b.size.y / 2.0
				
				if a.position.x > b.position.x:
					l.end_door.dir = Door.Direction.East
				else:
					l.end_door.dir = Door.Direction.West
				
				if a.position.y > b.position.y:
					l.start_door.dir = Door.Direction.North
				else:
					l.start_door.dir = Door.Direction.South


static func prims(graph: Array[GraphCell], grade: int):
	var unvisited := graph.duplicate()
	var visited: Array[GraphCell]
	
	var cost: Dictionary[GraphCell, int]
	var edge: Dictionary[GraphCell, GraphLink]
	
	for c in unvisited:
		cost[c] = 1000000
	
	cost[graph[0]] = 0
	
	while not unvisited.is_empty():
		var current: GraphCell = null
		var current_cost := 100000000
		
		for c in unvisited:
			if cost[c] < current_cost:
				current_cost = cost[c]
				current = c
		
		unvisited.erase(current)
		visited.append(current)
		
		for l in current.links:
			if l.to.grade > grade or l.from.grade > grade:
				continue
			if l.to in unvisited and l.length < cost[l.to]:
				cost[l.to] = l.length
				edge[l.to] = l
	
	for c in graph:
		if c in edge:
			var e := edge[c]
			if e.from.grade > grade or e.to.grade > grade:
				continue
			e.disabled = false


static func roundm(
	n: float,
	m: float
) -> float:
	return floor(
		(n * m - 1.0) / m
	) * m


static func roundmv(
	v: Vector2,
	m: float
) -> Vector2:
	return Vector2(
		roundm(v.x, m),
		roundm(v.y, m)
	)


static func force_away(a: Rect2, b: Rect2) -> Vector2:
	var delta := a.get_center() - b.get_center()
	return delta.normalized()


static func get_random_point(min_radius: float, max_radius: float) -> Vector2:
	var angle := randf() * TAU
	var radius = sqrt(randf() * (max_radius * max_radius - min_radius * min_radius) + min_radius * min_radius)
	
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	
	return Vector2(x, y)
