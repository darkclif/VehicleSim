extends ImmediateGeometry

var arrows = {}

func drawarrow(a, b, color):
	var thick = 0.05
	var vect = b - a
	var up = Vector3(0, 1, 0)
	var side = up.cross(vect).normalized()
	
	begin(Mesh.PRIMITIVE_TRIANGLES)
	set_color(color)
	
	# Body part 1
	add_vertex(a - side * thick)
	add_vertex(a + side * thick + vect)
	add_vertex(a - side * thick + vect)
	
	# Body part 2
	add_vertex(a + side * thick)
	add_vertex(a + side * thick + vect)
	add_vertex(a - side * thick)
	
	# Arrow 
	add_vertex(a + vect + 4 * side * thick)
	add_vertex(a + vect + 4 * thick * vect.normalized())
	add_vertex(a + vect - 4 * side * thick)
	
	end()

func _ready():
	pass

func update_arrow(name, vect, color):
	self.arrows[name] = {"vect": vect, "color": color}

func draw_arrows():
	for k in self.arrows.keys():
		drawarrow(Vector3(0, 0, 0), self.arrows[k]["vect"], self.arrows[k]["color"])

func _process(delta):
	self.clear()
	self.draw_arrows()
