extends Node2D

enum {
	EMPTY = 0, BLACK, WHITE, UNKNOWN,
	NONE = 0, ONE, TWO, THREE, FOUR, FIVE, SIX,
	IX_EVAL = 0, IX_X, IX_Y,
}
const CELL_WD = 31		# 31*15 = 465
const N_HORZ = 15
const N_VERT = 15
const N_DIAGONAL = 10 + 1 + 10		# 斜め方向ビットマップ配列数

const ALPHA = -99999
const BETA = 99999

func xyToIX(x, y): return y*N_HORZ + x
func ixToX(ix: int): return ix % N_HORZ
func ixToY(ix: int): return ix / N_HORZ


func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
