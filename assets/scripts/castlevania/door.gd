extends Object
class_name Door

enum Direction {
	North,
	East,
	South,
	West
}

var offset: float
var dir := Direction.North


static func reverse(d: Direction):
	match d:
		Direction.North: return Direction.South
		Direction.East: return Direction.West
		Direction.South: return Direction.North
		Direction.West: return Direction.East
	return Direction.North


func straight(other: Door) -> bool:
	var a := int(dir) % 2
	var b := int(other.dir) % 2
	
	return a == b # Same parity


func position(rect: Rect2) -> Vector2:
	match dir:
		Direction.North: return Vector2(
			rect.position.x + offset,
			rect.position.y
		)
		Direction.East: return Vector2(
			rect.end.x,
			rect.position.y + offset
		)
		Direction.South: return Vector2(
			rect.position.x + offset,
			rect.end.y
		)
		Direction.West: return Vector2(
			rect.position.x,
			rect.position.y + offset
		)
	return Vector2.ZERO
