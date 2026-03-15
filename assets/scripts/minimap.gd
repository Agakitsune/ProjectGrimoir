extends Node2D

var castle: Castlevania

func _draw() -> void:
	var middle := Vector2.ZERO
	
	for c in castle._cell:
		if not c.visible:
			continue
		var tmp := c.rect
		tmp.position += middle
		var clr := Color.DARK_CYAN
		match c.grade:
			0:
				clr = Color.CRIMSON
			1:
				clr = Color.CYAN
		if c == castle._spawn:
			clr = Color.GOLD
		draw_rect(tmp, clr, false)
	
	#for c: GraphCell in castle._main_graph:
		#var clr := Color.GREEN
		#
		#draw_circle(c.pos + middle, 6.0, clr, false)
		#
		#for l in c.links:
			#if l.to.grade > 0:
				#continue
			#if not l.disabled:
				#draw_line(c.pos + middle, l.to.pos + middle, clr, 3.0)
				#
				#if l.start_door:
					#var start := l.start_door.position(c.rect)
					#var end := l.end_door.position(l.to.rect)
					#
					#if l.start_door.straight(l.end_door):
						#draw_line(
							#start + middle,
							#end + middle,
							#Color.ALICE_BLUE,
							#4.0
						#)
					#else:
						#var mid := start
						#var a := int(l.start_door.dir) % 2
						#
						#if a == 0:
							#mid.y = end.y
						#else:
							#mid.x = end.x
						#
						#draw_line(
							#start + middle,
							#mid + middle,
							#Color.ALICE_BLUE,
							#4.0
						#)
						#
						#draw_line(
							#mid + middle,
							#end + middle,
							#Color.ALICE_BLUE,
							#4.0
						#)
	#
	#for c: GraphCell in castle._sub_graph:
		#var clr := Color.RED
		#
		#draw_circle(c.pos + middle, 4.0, clr, false)
		#
		#for l in c.links:
			#if not l.disabled:
				#draw_line(c.pos + middle, l.to.pos + middle, clr, 1.0)
