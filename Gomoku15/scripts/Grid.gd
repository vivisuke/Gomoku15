extends ColorRect

const BD_WIDTH = 500
var N_HORZ = g.N_HORZ
var N_VERT = g.N_VERT
const FRAME_WD = 38
#const CELL_WD = (BD_WIDTH - FRAME_WD) / N_HORZ
const CELL_WD = 31		# 31*15 = 465
const ORG_X = CELL_WD*0.5
const ORG_Y = CELL_WD*0.5
var RT_END = CELL_WD*(N_HORZ-0.5)
var LW_END = CELL_WD*(N_VERT-0.5)

func _ready():
	for x in range(N_HORZ):
		var l = Label.new()
		l.text = "abcdefghijklmno"[x]
		l.set_position(Vector2(ORG_X+CELL_WD*x-4, -24))
		l.add_theme_color_override("font_color", Color.BLACK)
		add_child(l)
	for y in range(N_VERT):
		var l = Label.new()
		l.text = [" 1", " 2", " 3", " 4", " 5", " 6", " 7", " 8",
					" 9", "10", "11", "12", "13", "14", "15"][y]
		l.set_position(Vector2(-26, ORG_Y+CELL_WD*y-10))
		l.size.x = CELL_WD-10
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.add_theme_color_override("font_color", Color.BLACK)
		add_child(l)
	pass # Replace with function body.
func _process(delta):
	pass

func _draw():
	for x in range(N_HORZ):
		var wd = 2.5 if x == 0 || x == N_HORZ - 1 else 1
		draw_line(Vector2(ORG_X, ORG_Y+CELL_WD*x),
					Vector2(RT_END, ORG_Y+CELL_WD*x),
					Color.BLACK, wd)
		draw_line(Vector2(ORG_X+CELL_WD*x, ORG_Y),
					Vector2(ORG_X+CELL_WD*x, LW_END),
					Color.BLACK, wd)
	draw_circle(Vector2(ORG_X+CELL_WD*3, ORG_Y+CELL_WD*3), 3, Color.BLACK)
	draw_circle(Vector2(ORG_X+CELL_WD*11, ORG_Y+CELL_WD*3), 3, Color.BLACK)
	draw_circle(Vector2(ORG_X+CELL_WD*3, ORG_Y+CELL_WD*11), 3, Color.BLACK)
	draw_circle(Vector2(ORG_X+CELL_WD*11, ORG_Y+CELL_WD*11), 3, Color.BLACK)
	draw_circle(Vector2(ORG_X+CELL_WD*7, ORG_Y+CELL_WD*7), 3, Color.BLACK)
	pass
