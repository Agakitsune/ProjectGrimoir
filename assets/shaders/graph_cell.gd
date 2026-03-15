extends Object
class_name GraphCell

var rect: Rect2

var pos: Vector2
var links: Array[GraphLink]

var grade: int

var depth: int

var freeze := false
var visible := false

func link_with(other: GraphCell):
	var link := GraphLink.new()
	link.length = other.pos.distance_to(pos)
	link.from = self
	link.to = other
	
	links.push_back(link)
