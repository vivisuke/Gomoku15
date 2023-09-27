extends Node2D

enum {
	EMPTY = 0, BLACK, WHITE, UNKNOWN,
	NONE = 0, ONE, TWO, THREE, FOUR, FIVE, SIX,
	IX_EVAL = 0, IX_X, IX_Y,
}
const CELL_WD = 31		# 31*15 = 465
const N_HORZ = 15
const N_VERT = 15
const CX = (N_HORZ - 1) / 2			# 7 for 15x15
const CY = (N_VERT - 1) / 2
const N_DIAGONAL = 10 + 1 + 10		# 斜め方向ビットマップ配列数

const ALPHA = -99999
const BETA = 99999

var prio_pos = []

func xyToIX(x, y): return y*N_HORZ + x
func ixToX(ix: int): return ix % N_HORZ
func ixToY(ix: int): return ix / N_HORZ

class Board:
	const evtable = [		# 五路評価値テーブル
		0,		# ・・・・・
		1,		# ・・・・●
		1,		# ・・・●・
		4,		# ・・・●●
		1,		# ・・●・・
		2,		# ・・●・●
		4,		# ・・●●・
		15,		# ・・●●●
		1,		# ・●・・・
		2,		# ・●・・●
		2,		# ・●・●・
		10,		# ・●・●●
		4,		# ・●●・・
		10,		# ・●●・●
		20,		# ・●●●・
		150,	# ・●●●●
		1,		# ●・・・・
		2,		# ●・・・●
		2,		# ●・・●・
		6,		# ●・・●●
		2,		# ●・●・・
		5,		# ●・●・●
		10,		# ●・●●・
		100,	# ●・●●●
		4,		# ●●・・・
		6,		# ●●・・●
		10,		# ●●・●・
		100,	# ●●・●●
		15,		# ●●●・・
		100,	# ●●●・●
		150,	# ●●●●・
		9999,	# ●●●●●
	]
	#const prio_pos = [
	#]
	const IX_EV = 0
	const IX_B3 = 1
	const IX_W3 = 2
	const IX_B4 = 3
	const IX_W4 = 4
	const IX_B42 = 5		# 両端空四個数インデックス
	const IX_W42 = 6		# 両端空四個数インデックス
	#var nput
	var N_DIAGONAL = N_HORZ*2 - 4*2 - 1		# 斜め方向ビットマップ配列数
	var DIAGONAL_CENTER_IX = (N_DIAGONAL - 1) / 2
	var verbose = false
	var n_space				# 空欄数
	var n_calc_eval = 0		# 評価ノード数
	var eval = 0			# 評価値
	var n_black_three		# 黒三個数
	var n_white_three		# 白三個数
	var n_black_four		# 黒四個数
	var n_white_four		# 白四個数
	var n_black_four2		# 黒両端空四個数
	var n_white_four2		# 白両端空四個数
	var h_black = []		# 水平方向ビットマップ
	var h_white = []		# 水平方向ビットマップ
	var v_black = []		# 垂直方向ビットマップ
	var v_white = []		# 垂直方向ビットマップ
	var u_black = []		# 右上方向ビットマップ
	var u_white = []		# 右上方向ビットマップ
	var d_black = []		# 右下方向ビットマップ
	var d_white = []		# 右下方向ビットマップ
	var h_b_three = []		# 各水平方向ラインの黒 三 の数
	var h_w_three = []		# 各水平方向ラインの白 三 の数
	var h_b_four = []		# 各水平方向ラインの黒 四 の数
	var h_w_four = []		# 各水平方向ラインの白 四 の数
	var h_b_four2 = []		# 各水平方向ラインの黒 両端空四 の数
	var h_w_four2 = []		# 各水平方向ラインの白 両端空四 の数
	var v_b_three = []		# 各垂直方向ラインの黒 三 の数
	var v_w_three = []		# 各垂直方向ラインの白 三 の数
	var v_b_four = []		# 各垂直方向ラインの黒 四 の数
	var v_w_four = []		# 各垂直方向ラインの白 四 の数
	var v_b_four2 = []		# 各垂直方向ラインの黒 両端空四 の数
	var v_w_four2 = []		# 各垂直方向ラインの白 両端空四 の数
	var u_b_three = []		# 各右上方向ラインの黒 三 の数
	var u_w_three = []		# 各右上方向ラインの白 三 の数
	var u_b_four = []		# 各右上方向ラインの黒 四 の数
	var u_w_four = []		# 各右上方向ラインの白 四 の数
	var u_b_four2 = []		# 各右上方向ラインの黒 両端空四 の数
	var u_w_four2 = []		# 各右上方向ラインの白 両端空四 の数
	var d_b_three = []		# 各右下方向ラインの黒 三 の数
	var d_w_three = []		# 各右下方向ラインの白 三 の数
	var d_b_four = []		# 各右下方向ラインの黒 四 の数
	var d_w_four = []		# 各右下方向ラインの白 四 の数
	var d_b_four2 = []		# 各右下方向ラインの黒 両端空四 の数
	var d_w_four2 = []		# 各右下方向ラインの白 両端空四 の数
	var h_eval = []			# 水平方向評価値（黒から見た値）
	var v_eval = []			# 垂直方向評価値
	var u_eval = []			# 右上方向評価値
	var d_eval = []			# 右下方向評価値
	var move_hist = []				# 着手履歴
	var move_ix = -1				# 着手済みIX
	var put_order = []		# ソート済み着手順序、要素：[評価値, x, y]
	var put_order_ix = -1	# 次評価要素インデックス
	var prio_pos = []
	func _init():
		prio_pos = g.prio_pos
		h_black.resize(N_VERT)
		h_white.resize(N_VERT)
		v_black.resize(N_HORZ)
		v_white.resize(N_HORZ)
		u_black.resize(N_DIAGONAL)
		u_white.resize(N_DIAGONAL)
		d_black.resize(N_DIAGONAL)
		d_white.resize(N_DIAGONAL)
		h_b_three.resize(N_VERT)
		h_w_three.resize(N_VERT)
		v_black.resize(N_HORZ)
		v_white.resize(N_HORZ)
		u_black.resize(N_DIAGONAL)
		u_white.resize(N_DIAGONAL)
		d_black.resize(N_DIAGONAL)
		d_white.resize(N_DIAGONAL)
		h_b_three.resize(N_VERT)
		h_w_three.resize(N_VERT)
		h_b_four.resize(N_VERT)
		h_w_four.resize(N_VERT)
		h_b_four2.resize(N_VERT)
		h_w_four2.resize(N_VERT)
		v_b_three.resize(N_VERT)
		v_w_three.resize(N_VERT)
		v_b_four.resize(N_VERT)
		v_w_four.resize(N_VERT)
		v_b_four2.resize(N_VERT)
		v_w_four2.resize(N_VERT)
		u_b_three.resize(N_DIAGONAL)
		u_w_three.resize(N_DIAGONAL)
		u_b_four.resize(N_DIAGONAL)
		u_w_four.resize(N_DIAGONAL)
		u_b_four2.resize(N_DIAGONAL)
		u_w_four2.resize(N_DIAGONAL)
		d_b_three.resize(N_DIAGONAL)
		d_w_three.resize(N_DIAGONAL)
		d_b_four.resize(N_DIAGONAL)
		d_w_four.resize(N_DIAGONAL)
		d_b_four2.resize(N_DIAGONAL)
		d_w_four2.resize(N_DIAGONAL)
		h_eval.resize(N_VERT)
		v_eval.resize(N_HORZ)
		u_eval.resize(N_DIAGONAL)
		d_eval.resize(N_DIAGONAL)
		clear()
		#
		unit_test()
	func clear():
		#nput = 0
		n_space = N_HORZ * N_VERT
		eval = 0
		n_black_three = 0
		n_white_three = 0
		n_black_four = 0
		n_white_four = 0
		n_black_four2 = 0
		n_white_four2 = 0
		h_black.fill(0)
		h_white.fill(0)
		v_black.fill(0)
		v_white.fill(0)
		u_black.fill(0)
		u_white.fill(0)
		d_black.fill(0)
		d_white.fill(0)
		h_b_three.fill(0)
		h_w_three.fill(0)
		h_b_four.fill(0)
		h_w_four.fill(0)
		h_b_four2.fill(0)
		h_w_four2.fill(0)
		v_b_three.fill(0)
		v_w_three.fill(0)
		v_b_four.fill(0)
		v_w_four.fill(0)
		v_b_four2.fill(0)
		v_w_four2.fill(0)
		u_b_three.fill(0)
		u_w_three.fill(0)
		u_b_four.fill(0)
		u_w_four.fill(0)
		u_b_four2.fill(0)
		u_w_four2.fill(0)
		d_b_three.fill(0)
		d_w_three.fill(0)
		d_b_four.fill(0)
		d_w_four.fill(0)
		d_b_four2.fill(0)
		d_w_four2.fill(0)
		h_eval.fill(0)
		v_eval.fill(0)
		u_eval.fill(0)
		d_eval.fill(0)
		

	#  6  7    12
	#	┌────────┐→x
	#   │＼＼…＼        │  
	#   │＼＼    ＼      │  
	#   │：        ＼    │  
	#  0│＼          ＼  │  
	#   │  ＼          ＼│  
	#   │    ＼        ：│  
	#   │      ＼    ＼＼│  
	#   │        ＼…＼＼│  
	#   └────────┘  
	#   ↓y
	func xyToDrIxMask(x, y) -> Array:	# return [ix, mask, nbit]
		var ix = x - y + DIAGONAL_CENTER_IX
		if ix < 0 || ix >= N_DIAGONAL: return [-1, 0]
		if ix <= DIAGONAL_CENTER_IX:
			return [ix, 1<<(g.N_HORZ-1-x+(ix-DIAGONAL_CENTER_IX)), DIAGONAL_CENTER_IX-1+ix]
		else:
			return [ix, 1<<(g.N_HORZ-1-y-(ix-DIAGONAL_CENTER_IX)), 17-ix]

	#             0         6
	#	┌────────┐→x
	#   │        ／…／／│  
	#   │      ／    ／／│  
	#   │    ／        ：│  
	#   │  ／          ／│12  
	#   │／          ／  │  
	#   │：        ／    │  
	#   │／／    ／      │  
	#   │／／…／        │  
	#   └────────┘  
	#   ↓y
	func xyToUrIxMask(x, y) -> Array:	# return [ix, mask, nbit]
		var ix = x + y - 10 + DIAGONAL_CENTER_IX
		if ix < 0 || ix > 12: return [-1, 0]
		if ix <= DIAGONAL_CENTER_IX:
			return [ix, 1<<(g.N_HORZ-1-x+(ix-DIAGONAL_CENTER_IX)), DIAGONAL_CENTER_IX-1+ix]
		else:
			return [ix, 1<<(y-(ix-DIAGONAL_CENTER_IX)), 17-ix]
	func is_empty(x, y):	# h_black, h_white のみを参照
		var mask = 1 << (N_HORZ - 1 - x)
		return h_black[y]&mask == 0 && h_white[y]&mask == 0
	func get_color(x, y):	# h_black, h_white のみを参照
		var mask = 1 << (N_HORZ - 1 - x)
		if (h_black[y]&mask) != 0: return BLACK
		if (h_white[y]&mask) != 0: return WHITE
		return EMPTY
	func get_color_v(x, y):	# v_black, v_white のみを参照
		var mask = 1 << (N_VERT - 1 - y)
		if (v_black[x]&mask) != 0: return BLACK
		if (v_white[x]&mask) != 0: return WHITE
		return EMPTY
	func get_color_u(x, y):	# u_black, u_white のみを参照
		var t = xyToUrIxMask(x, y)
		if t[0] < 0: return UNKNOWN
		if (u_black[t[0]] & t[1]) != 0: return BLACK
		if (u_white[t[0]] & t[1]) != 0: return WHITE
		return EMPTY
	func get_color_d(x, y):	# d_black, d_white のみを参照
		var t = xyToDrIxMask(x, y)
		if t[0] < 0: return UNKNOWN
		if (d_black[t[0]] & t[1]) != 0: return BLACK
		if (d_white[t[0]] & t[1]) != 0: return WHITE
		return EMPTY
	# 着手・盤面評価
	func put_color(x, y, col):		# 前提：(x, y) は空欄、col：BLACK or WHITE
		#nput += 1
		n_space -= 1
		var mask = 1 << (N_HORZ - 1 - x)
		if col == BLACK:
			h_black[y] |= mask
		elif col == WHITE:
			h_white[y] |= mask
		mask = 1 << (N_HORZ - 1 - y)
		if col == BLACK:
			v_black[x] |= mask
		elif col == WHITE:
			v_white[x] |= mask
		# done: 斜めビットマップ更新
		var t = xyToUrIxMask(x, y)
		if t[0] >= 0:
			if col == BLACK:
				u_black[t[0]] |= t[1]
			elif col == WHITE:
				u_white[t[0]] |= t[1]
		t = xyToDrIxMask(x, y)
		if t[0] >= 0:
			if col == BLACK:
				d_black[t[0]] |= t[1]
			elif col == WHITE:
				d_white[t[0]] |= t[1]
		eval_putxy(x, y, BLACK+WHITE-col)	# 結果は eval に格納される
	func remove_color(x, y):
		#nput -= 1
		n_space += 1
		var mask = 1 << (N_HORZ - 1 - x)
		h_black[y] &= ~mask
		h_white[y] &= ~mask
		mask = 1 << (N_HORZ - 1 - y)
		v_black[x] &= ~mask
		v_white[x] &= ~mask
		# done: 縦・斜めビットマップ更新
		var t = xyToUrIxMask(x, y)
		if t[0] >= 0:
			u_black[t[0]] &= ~t[1]
			u_white[t[0]] &= ~t[1]
		t = xyToDrIxMask(x, y)
		if t[0] >= 0:
			d_black[t[0]] &= ~t[1]
			d_white[t[0]] &= ~t[1]
		eval_putxy(x, y, EMPTY)
	const is34table = [		# 三四テーブル
		NONE,		# ・・・・・
		NONE,		# ・・・・●
		NONE,		# ・・・●・
		NONE,		# ・・・●●
		NONE,		# ・・●・・
		NONE,		# ・・●・●
		NONE,		# ・・●●・
		THREE,		# ・・●●●
		NONE,		# ・●・・・
		NONE,		# ・●・・●
		NONE,		# ・●・●・
		THREE,		# ・●・●●
		NONE,		# ・●●・・
		THREE,		# ・●●・●
		THREE,		# ・●●●・
		FOUR,		# ・●●●●
		NONE,		# ●・・・・
		NONE,		# ●・・・●
		NONE,		# ●・・●・
		NONE,		# ●・・●●
		NONE,		# ●・●・・
		NONE,		# ●・●・●
		THREE,		# ●・●●・
		FOUR,		# ●・●●●
		NONE,		# ●●・・・
		NONE,		# ●●・・●
		THREE,		# ●●・●・
		FOUR,		# ●●・●●
		THREE,		# ●●●・・
		FOUR,		# ●●●・●
		FOUR,		# ●●●●・
		FIVE,		# ●●●●●
	]
	func is_forced(b5, w5):
		return is34table[b5] != NONE && w5 == 0
		#return (b5 == 0b01110 || b5 == 0b01111 || b5 == 0b10111 ||
		#		b5 == 0b11011 || b5 == 0b11101 || b5 == 0b11110)
	##func eval_bitmap(black, white, nbit, nxcol):		# bitmap（下位 nbit）を評価
	##	if black == 0 && white == 0: return 0
	##	if verbose: print("black = 0x%x" % black)
	##	var ev = 0
	##	for i in range(nbit - 4):
	##		var b5 = black & 0x1f
	##		var w5 = white & 0x1f
	##		if b5 != 0:
	##			if w5 == 0:
	##				ev += evtable[b5]
	##				if nxcol == BLACK && is_forced(b5, w5):
	##					ev += evtable[b5] * 2
	##				if verbose: print("b5 = 0x%x, ev = %d" % [b5, ev])
	##			else:
	##				pass	# 黒白両方ある場合は、評価値: 0
	##		else:
	##			if w5 != 0:
	##				ev -= evtable[w5]
	##				if nxcol == WHITE && is_forced(w5, b5):
	##					ev -= evtable[w5] * 2
	##			else:
	##				pass	# 黒白両方空欄のみの場合は、評価値: 0
	##		black >>= 1
	##		white >>= 1
	##	return ev
	# bitmap（下位 nbit）を評価、さらに 三・四の個数を数える
	func eval_bitmap_34(black, white, nbit) -> Array:		# return: [eval, b3, w3, b4, w4, b42, w42]
		var rv = [0, 0, 0, 0, 0, 0, 0]
		if black != 0 || white != 0:
			var not_zero = black | white | (1<<nbit)
			#var is_lt_black = black & (1<<nbit)
			var is_rt_zero : bool = false
			var is_rt_black : bool = false
			var is_rt_white : bool = false
			for i in range(nbit - 4):
				var b5 = black & 0x1f
				var w5 = white & 0x1f
				if b5 != 0:
					if w5 == 0:
						rv[IX_EV] += evtable[b5]
						#if verbose: print("b5 = 0x%x, ev = %d" % [b5, ev])
						var is34 = is34table[b5]
						if is34 == FOUR:
							rv[IX_B4] += 1
							#var ltz = (not_zero&0b100000)==0
							#var b = b5 == 0b11110
							if (b5 == 0b01111 && is_rt_zero) || (b5 == 0b11110 && (not_zero&0b100000)==0):
								rv[IX_B42] += 1
							black >>= 4
							white >>= 4
						#elif is34 == THREE: rv[IX_B3] += 1
						else:
							if ((!(black&0b100000) && b5 == 0b01110 && !is_rt_black) ||
								((b5 == 0b11010 || b5 == 0b10110) && !(not_zero&0b100000)) ||
								((b5 == 0b01101 || b5 == 0b01011) && !is_rt_black && !is_rt_white)):
									rv[IX_B3] += 1
									black >>= 3
									white >>= 3
					else:
						pass	# 黒白両方ある場合は、評価値: 0
				else:
					if w5 != 0:
						rv[IX_EV] -= evtable[w5]
						var is34 = is34table[w5]
						if is34 == FOUR:
							rv[IX_W4] += 1
							if (w5 == 0b01111 && is_rt_zero) || (w5 == 0b11110 && (not_zero&0b100000)==0):
								rv[IX_W42] += 1
							black >>= 4
							white >>= 4
						#elif is34 == THREE: rv[IX_W3] += 1
						else:
							if ((!(white&0b100000) && w5 == 0b01110 && !is_rt_white) ||
								((w5 == 0b11010 || w5 == 0b10110) && !(not_zero&0b100000)) ||
								((w5 == 0b01101 || w5 == 0b01011) && !is_rt_black && !is_rt_white)):
									rv[IX_W3] += 1
									black >>= 3
									white >>= 3
					else:
						pass	# 黒白両方空欄のみの場合は、評価値: 0
				is_rt_zero = ((black|white)&1) == 0
				is_rt_black = (black&1) != 0
				is_rt_white = (white&1) != 0
				not_zero >>= 1
				black >>= 1
				white >>= 1
		return rv
	func calc_eval_diff(next_color):	# 評価関数計算、差分計算
		n_calc_eval += 1
		if next_color == BLACK:
			if n_black_four != 0:		# 四が出来ている
				return 9000
			if n_white_four2 != 0:		# 白に両四が出来ている
				return -9000
			if n_white_four != 0:		# 白に四が出来ている
				if n_white_three != 0:
					return eval - 2000	# 白に四三が出来ている
				else:
					return eval - 200
			if n_black_three != 0:
				return eval + 50
		else:
			if n_white_four != 0:		# 四が出来ている
				return -9000
			if n_black_four2 != 0:			# 黒に両四が出来ている
				return 9000
			if n_black_four != 0:		# 黒に四が出来ている
				if n_black_three != 0:
					return eval + 2000	# 黒に四三が出来ている
				else:
					return eval + 200
			if n_white_three != 0:
				return eval - 50
		return eval
	##func calc_eval(next_color):			# 評価関数計算、非差分計算
	##	eval = 0
	##	for y in range(N_VERT):
	##		h_eval[y] = eval_bitmap(h_black[y], h_white[y], N_HORZ, next_color)
	##		eval += h_eval[y]
	##	for x in range(N_HORZ):
	##		v_eval[x] = eval_bitmap(v_black[x], v_white[x], N_VERT, next_color)
	##		eval += v_eval[x]
	##	var len = 5
	##	var d = 1
	##	for i in range(N_DIAGONAL):
	##		u_eval[i] = eval_bitmap(u_black[i], u_white[i], len, next_color)
	##		eval += u_eval[i]
	##		d_eval[i] = eval_bitmap(d_black[i], d_white[i], len, next_color)
	##		eval += d_eval[i]
	##		len += d
	##		if len == 11: d = -1
	# (x, y) に着手した場合の評価値差分評価
	func eval_putxy(x, y, next_color):
		eval -= h_eval[y]
		var rv = eval_bitmap_34(h_black[y], h_white[y], N_HORZ)
		h_eval[y] = rv[IX_EV]
		eval += h_eval[y]
		n_black_three += rv[IX_B3] - h_b_three[y]
		h_b_three[y] = rv[IX_B3]
		n_white_three += rv[IX_W3] - h_w_three[y]
		h_w_three[y] = rv[IX_W3]
		n_black_four += rv[IX_B4] - h_b_four[y]
		h_b_four[y] = rv[IX_B4]
		n_white_four += rv[IX_W4] - h_w_four[y]
		h_w_four[y] = rv[IX_W4]
		n_black_four2 += rv[IX_B42] - h_b_four2[y]
		h_b_four2[y] = rv[IX_B42]
		n_white_four2 += rv[IX_W42] - h_w_four2[y]
		h_w_four2[y] = rv[IX_W42]
		#
		eval -= v_eval[x]
		rv= eval_bitmap_34(v_black[x], v_white[x], N_VERT)
		v_eval[x] = rv[IX_EV]
		eval += v_eval[x]
		n_black_three += rv[IX_B3] - v_b_three[x]
		v_b_three[x] = rv[IX_B3]
		n_white_three += rv[IX_W3] - v_w_three[x]
		v_w_three[x] = rv[IX_W3]
		n_black_four += rv[IX_B4] - v_b_four[x]
		v_b_four[x] = rv[IX_B4]
		n_white_four += rv[IX_W4] - v_w_four[x]
		v_w_four[x] = rv[IX_W4]
		n_black_four2 += rv[IX_B42] - v_b_four2[x]
		v_b_four2[x] = rv[IX_B42]
		n_white_four2 += rv[IX_W42] - v_w_four2[x]
		v_w_four2[x] = rv[IX_W42]
		#
		var t = xyToUrIxMask(x, y)
		var ix = t[0]
		if ix >= 0:
			eval -= u_eval[ix]
			rv = eval_bitmap_34(u_black[ix], u_white[ix], t[2])
			u_eval[ix] = rv[IX_EV]
			eval += u_eval[ix]
			n_black_three += rv[IX_B3] - u_b_three[ix]
			u_b_three[ix] = rv[IX_B3]
			n_white_three += rv[IX_W3] - u_w_three[ix]
			u_w_three[ix] = rv[IX_W3]
			n_black_four += rv[IX_B4] - u_b_four[ix]
			u_b_four[ix] = rv[IX_B4]
			n_white_four += rv[IX_W4] - u_w_four[ix]
			u_w_four[ix] = rv[IX_W4]
			n_black_four2 += rv[IX_B42] - u_b_four2[ix]
			u_b_four2[ix] = rv[IX_B42]
			n_white_four2 += rv[IX_W42] - u_w_four2[ix]
			u_w_four2[ix] = rv[IX_W42]
		t = xyToDrIxMask(x, y)
		ix = t[0]
		if ix >= 0:
			eval -= d_eval[ix]
			rv= eval_bitmap_34(d_black[ix], d_white[ix], t[2])
			d_eval[ix] = rv[IX_EV]
			eval += d_eval[ix]
			n_black_three += rv[IX_B3] - d_b_three[ix]
			d_b_three[ix] = rv[IX_B3]
			n_white_three += rv[IX_W3] - d_w_three[ix]
			d_w_three[ix] = rv[IX_W3]
			n_black_four += rv[IX_B4] - d_b_four[ix]
			d_b_four[ix] = rv[IX_B4]
			n_white_four += rv[IX_W4] - d_w_four[ix]
			d_w_four[ix] = rv[IX_W4]
			n_black_four2 += rv[IX_B42] - d_b_four2[ix]
			d_b_four2[ix] = rv[IX_B42]
			n_white_four2 += rv[IX_W42] - d_w_four2[ix]
			d_w_four2[ix] = rv[IX_W42]
		return eval
	func is_five_sub(bitmap: int):		# 着手後、五目並んだか？
		#var a = bitmap
		#for i in range(4):
		#	bitmap >>= 1
		#	a &= bitmap
		var a = bitmap & (bitmap>>1) & (bitmap>>2) & (bitmap>>3) & (bitmap>>4)
		return a != 0
	#func is_five_sub(b: int, bitmap: int):		# b に着手後、五目並んだか？
		#var mask = (b << 5) - 1			# 0b1 → 0b11111
		#mask -= b - 1					# 0b2 → 0b111110
		#for i in range(5):
		#	if (bitmap & mask) == mask: return true
		#	if (mask&1) == 1: break
		#	mask >>= 1
		#return false
	func is_five(x, y, col):		# (x, y) に着手後、五目並んだか？
		var h = 1 << (N_HORZ - 1 - x)
		var v = 1 << (N_HORZ - 1 - y)
		var d = xyToDrIxMask(x, y)
		var u = xyToUrIxMask(x, y)
		if col == BLACK:
			if is_five_sub(h_black[y]): return true
			if is_five_sub(v_black[x]): return true
			if d[0] >= 0 && is_five_sub(d_black[d[0]]): return true
			if u[0] >= 0 && is_five_sub(u_black[u[0]]): return true
		elif col == WHITE:
			if is_five_sub(h_white[y]): return true
			if is_five_sub(v_white[x]): return true
			if d[0] >= 0 && is_five_sub(d_white[d[0]]): return true
			if u[0] >= 0 && is_five_sub(u_white[u[0]]): return true
		return false
	func is_six_sub(bitmap: int):		# 着手後、六目並んだか？
		var a = bitmap & (bitmap>>1) & (bitmap>>2) & (bitmap>>3) & (bitmap>>4) & (bitmap>>5)
		return a != 0
	func is_six(x, y, col):		# (x, y) に着手後、六目並んだか？
		var h = 1 << (N_HORZ - 1 - x)
		var v = 1 << (N_HORZ - 1 - y)
		var d = xyToDrIxMask(x, y)
		var u = xyToUrIxMask(x, y)
		if col == BLACK:
			if is_six_sub(h_black[y]): return true
			if is_six_sub(v_black[x]): return true
			if d[0] >= 0 && is_six_sub(d_black[d[0]]): return true
			if u[0] >= 0 && is_six_sub(u_black[u[0]]): return true
		elif col == WHITE:
			if is_six_sub(h_white[y]): return true
			if is_six_sub(v_white[x]): return true
			if d[0] >= 0 && is_six_sub(d_white[d[0]]): return true
			if u[0] >= 0 && is_six_sub(u_white[u[0]]): return true
		return false
	#func is_four_sub(b: int, bitmap: int):		# 黒が b に着手後、四目並んだか？
		#var a = bitmap & (bitmap>>1) & (bitmap>>2) & (bitmap>>3)
		#return a != 0
	func is_four_sub(p: int, black:int, white: int):		# p に着手後、四目並んだか？
		while p > 0b10000:		# 着手箇所の影響範囲外を削除
			black >>= 1
			white >>= 1
			p >>= 1
		while p != 0:
			if (white & 0b11111) == 0 && is34table[black & 0b11111] >= FOUR:
				return true
			black >>= 1
			white >>= 1
			p >>= 1
		return false
	func is_four(x, y, col):		# (x, y) に着手後、活四ができたか？
		var h = 1 << (N_HORZ - 1 - x)
		var v = 1 << (N_HORZ - 1 - y)
		var d = xyToDrIxMask(x, y)
		var u = xyToUrIxMask(x, y)
		if col == BLACK:
			if is_four_sub(1<<(10-x), h_black[y], h_white[y]): return true
			if is_four_sub(1<<(10-y), v_black[x], v_white[x]): return true
			if d[0] >= 0 && is_four_sub(d[1], d_black[d[0]], d_white[d[0]]): return true
			if u[0] >= 0 && is_four_sub(u[1], u_black[u[0]], u_white[u[0]]): return true
		elif col == WHITE:
			if is_four_sub(1<<(10-x), h_white[y], h_black[y]): return true
			if is_four_sub(1<<(10-y), v_white[x], v_black[x]): return true
			if d[0] >= 0 && is_four_sub(d[1], d_white[d[0]], d_black[d[0]]): return true
			if u[0] >= 0 && is_four_sub(u[1], u_white[u[0]], u_black[u[0]]): return true
		return false
	func is_three_sub(p: int, black:int, white: int, nbit):		# p に着手後、活三ができたか？
		black <<= 1
		white <<= 1
		white |= 1 | (1<<(nbit+1))		# 壁を付加
		while p > 0b100000:		# 着手箇所の影響範囲外を削除
			black >>= 1
			white >>= 1
			p >>= 1
		while p > 1:
			if (white & 0b111110) == 0:
				var b5 = black & 0b111110
				if b5 == 0b011100 && ((white &0b1000000) == 0 || (white &0b0000001) == 0):
					return true
				if (b5 == 0b010110 || b5 == 0b011010) && (white &0b100001) == 0:
					return true
				if (b5 == 0b101100 || b5 == 0b110100) && (white &0b1000010) == 0:
					return true
			black >>= 1
			white >>= 1
			p >>= 1
		return false
	func is_three(x, y, col):		# (x, y) に着手後、活三ができたか？
		var h = 1 << (N_HORZ - 1 - x)
		var v = 1 << (N_HORZ - 1 - y)
		var d = xyToDrIxMask(x, y)
		var u = xyToUrIxMask(x, y)
		if col == BLACK:
			if is_three_sub(1<<(10-x), h_black[y], h_white[y], N_HORZ): return true
			if is_three_sub(1<<(10-y), v_black[x], v_white[x], N_VERT): return true
			if d[0] >= 0 && is_three_sub(d[1], d_black[d[0]], d_white[d[0]], d[2]): return true
			if u[0] >= 0 && is_three_sub(u[1], u_black[u[0]], u_white[u[0]], u[2]): return true
		elif col == WHITE:
			if is_three_sub(1<<(10-x), h_white[y], h_black[y], N_HORZ): return true
			if is_three_sub(1<<(10-y), v_white[x], v_black[x], N_VERT): return true
			if d[0] >= 0 && is_three_sub(d[1], d_white[d[0]], d_black[d[0]], d[2]): return true
			if u[0] >= 0 && is_three_sub(u[1], u_white[u[0]], u_black[u[0]], u[2]): return true
		return false
	func is_legal_put(x, y, color):
		if color == WHITE: return true
		if is_six(x, y, BLACK): return false
		var n3 = 0		# 活三 個数
		var n4 = 0		# 活四 個数
		var h = 1 << (N_HORZ - 1 - x)
		var v = 1 << (N_HORZ - 1 - y)
		var d = xyToDrIxMask(x, y)
		var u = xyToUrIxMask(x, y)
		if is_four_sub(1<<(10-x), h_black[y], h_white[y]):
			n4 += 1
		elif is_three_sub(1<<(10-x), h_black[y], h_white[y], N_HORZ):
			n3 += 1
		if is_four_sub(1<<(10-y), v_black[x], v_white[x]):
			n4 += 1
		elif is_three_sub(1<<(10-y), v_black[x], v_white[x], N_VERT):
			n3 += 1
		if d[0] >= 0 && is_four_sub(d[1], d_black[d[0]], d_white[d[0]]):
			n4 += 1
		elif d[0] >= 0 && is_three_sub(d[1], d_black[d[0]], d_white[d[0]], d[2]):
			n3 += 1
		if u[0] >= 0 && is_four_sub(u[1], u_black[u[0]], u_white[u[0]]):
			n4 += 1
		elif u[0] >= 0 && is_three_sub(u[1], u_black[u[0]], u_white[u[0]], u[2]):
			n3 += 1
		return n4 < 2 && n3 < 2
	func sel_move_randomly(next_color) -> Vector2i:
		#var op = Vector2i(-1, -1)
		var lst = []
		if next_color == BLACK:		# 黒番
			var mx = -99999
			for y in range(N_VERT):
				for x in range(N_HORZ):
					if is_empty(x, y):
						put_color(x, y, next_color)
						if is_legal_put(x, y, next_color):
							var ev = calc_eval_diff(WHITE) + randfn(0.0, 10)
							if ev > mx:
								mx = ev
								lst = [Vector2i(x, y)]
							elif ev == mx:
								lst.push_back(Vector2i(x, y))
						remove_color(x, y)
		else:						# 白番
			var mn = 99999
			for y in range(N_VERT):
				for x in range(N_HORZ):
					if is_empty(x, y):
						put_color(x, y, next_color)
						var ev = calc_eval_diff(BLACK) + randfn(0.0, 10)
						if ev < mn:
							mn = ev
							#op = Vector2i(x, y)
							lst = [Vector2i(x, y)]
						elif ev == mn:
							lst.push_back(Vector2i(x, y))
						remove_color(x, y)
		if lst.size() == 1: return lst[0]
		var r = randi() % lst.size()
		return lst[r]
	func put_minmax(next_color) -> Vector2i:
		#var op = Vector2i(-1, -1)
		var lst = []
		if next_color == BLACK:		# 黒番
			var mx = -99999
			for y in range(N_VERT):
				for x in range(N_HORZ):
					if is_empty(x, y):
						put_color(x, y, next_color)
						if is_legal_put(x, y, next_color):
							calc_eval_diff(WHITE)
							if eval > mx:
								mx = eval
								#op = Vector2i(x, y)
								lst = [Vector2i(x, y)]
							elif eval == mx:
								lst.push_back(Vector2i(x, y))
						remove_color(x, y)
		else:						# 白番
			var mn = 99999
			for y in range(N_VERT):
				for x in range(N_HORZ):
					if is_empty(x, y):
						put_color(x, y, next_color)
						calc_eval_diff(BLACK)
						if eval < mn:
							mn = eval
							#op = Vector2i(x, y)
							lst = [Vector2i(x, y)]
						elif eval == mn:
							lst.push_back(Vector2i(x, y))
						remove_color(x, y)
		if lst.size() == 1: return lst[0]
		var r = randi() % lst.size()
		return lst[r]
	func build_put_order(next_color):
		put_order = []
		for i in range(prio_pos.size()):
			var x = prio_pos[i][0]
			var y = prio_pos[i][1]
			var ix = y * N_HORZ + x
			if is_empty(x, y):
				put_color(x, y, next_color)
				if is_legal_put(x, y, next_color):
					if is_five(x, y, next_color):	# 五が出来た場合
						var ev = 9999 if next_color == BLACK else -9999
						put_order.push_back([ev, x, y])
					else:
						#calc_eval(next_color)
						var ev = calc_eval_diff((BLACK+WHITE)-next_color)
						put_order.push_back([ev, x, y])
				remove_color(x, y)
		#print(put_order, "\n")
		if next_color == BLACK:
			put_order.sort_custom(func(lhs, rhs): return lhs[0] > rhs[0])
		else:
			put_order.sort_custom(func(lhs, rhs): return lhs[0] < rhs[0])
		var v = put_order[0][IX_EVAL]
		var sz = 1
		while sz < put_order.size() && put_order[sz][IX_EVAL] == v: sz += 1
		if sz > 1:
			var ta = []
			ta.resize(sz)
			for i in range(sz): ta[i] = put_order[i]
			ta.shuffle()
			for i in range(sz): put_order[i] = ta[i]
		# undone: 最大/最小値の部分をシャフル
		#print(put_order, "\n")
		#alpha = g.ALPHA
		#beta = g.BETA
		put_order_ix = 0
	func alpha_beta(next_color, alpha, beta, depth) -> int:
		if depth <= 0:
			#calc_eval(next_color)
			#return eval
			return calc_eval_diff(next_color)
		if next_color == BLACK:		# 黒番
			for i in range(prio_pos.size()):
				var x = prio_pos[i][0]
				var y = prio_pos[i][1]
				if is_empty(x, y):
					put_color(x, y, next_color)
					if is_legal_put(x, y, next_color):
						if is_five(x, y, next_color):
							remove_color(x, y)
							return 9000
						var ev = alpha_beta(WHITE, alpha, beta, depth-1)
						remove_color(x, y)
						if ev > alpha:
							alpha = ev
						if alpha >= beta:
							return alpha
					else:
						remove_color(x, y)
			return alpha
		else:						# 白番
			for i in range(prio_pos.size()):
				var x = prio_pos[i][0]
				var y = prio_pos[i][1]
				if is_empty(x, y):
					put_color(x, y, next_color)
					if is_five(x, y, next_color):
						remove_color(x, y)
						return -9000
					var ev = alpha_beta(BLACK, alpha, beta, depth-1)
					remove_color(x, y)
					if ev < beta:
						beta = ev
					if alpha >= beta:
						return beta
			return beta
	func do_alpha_beta_search(next_color, depth) -> Vector2i:
		print("depth = ", depth)
		#var op = Vector2i(-1, -1)
		var ev_pos = []		# 要素：[評価値, x, y] 配列
		var lst = []
		var best = Vector2i(-1, -1)
		if next_color == BLACK:		# 黒番
			for i in range(prio_pos.size()):
				var x = prio_pos[i][0]
				var y = prio_pos[i][1]
				if is_empty(x, y):
					put_color(x, y, BLACK)
					if is_legal_put(x, y, BLACK):
						calc_eval_diff(WHITE)
						ev_pos.push_back([eval, x, y])
					remove_color(x, y)
			ev_pos.sort_custom(func(lhs, rhs): return lhs[0] > rhs[0])
			if depth <= 1:
				# done：最大値要素をシャフル
				var ev = ev_pos[0][0]
				var sz = 1
				while (sz < ev_pos.size() && ev_pos[sz][0] == ev):
					sz += 1
				if sz > 1:
					ev_pos.resize(sz)
					ev_pos.shuffle()
				best = Vector2i(ev_pos[0][1], ev_pos[0][2])
			else:
				var alpha = ALPHA
				for i in range(ev_pos.size()):
					var x = ev_pos[i][1]
					var y = ev_pos[i][2]
					if is_empty(x, y):
						put_color(x, y, BLACK)
						if is_legal_put(x, y, BLACK):
							var ev = alpha_beta(WHITE, alpha, BETA, depth-1)
							if ev > alpha:
								alpha = ev
								best = Vector2i(x, y)
						remove_color(x, y)
		else:						# 白番
			for i in range(prio_pos.size()):
				var x = prio_pos[i][0]
				var y = prio_pos[i][1]
				if is_empty(x, y):
					put_color(x, y, WHITE)
					calc_eval_diff(BLACK)
					ev_pos.push_back([eval, x, y])
					remove_color(x, y)
			ev_pos.sort_custom(func(lhs, rhs): return lhs[0] < rhs[0])
			if depth <= 1:
				# done：最大値要素をシャフル
				var ev = ev_pos[0][0]
				var sz = 1
				while (sz < ev_pos.size() && ev_pos[sz][0] == ev):
					sz += 1
				if sz > 1:
					ev_pos.resize(sz)
					ev_pos.shuffle()
				best = Vector2i(ev_pos[0][1], ev_pos[0][2])
			else:
				var beta = 99999
				for i in range(ev_pos.size()):
					var x = ev_pos[i][1]
					var y = ev_pos[i][2]
					if is_empty(x, y):
						put_color(x, y, WHITE)
						var ev = alpha_beta(BLACK, ALPHA, beta, depth-1)
						if ev < beta:
							beta = ev
							best = Vector2i(x, y)
						remove_color(x, y)
		return best
		#if lst.size() == 1: return lst[0]
		#var r = randi() % lst.size()
		#return lst[r]
	func print():
		for y in range(N_VERT):
			var txt = ""
			var mask = 1 << 10
			for i in range(N_HORZ):
				if (h_black[y] & mask) != 0: txt += " X"
				elif (h_white[y] & mask) != 0: txt += " O"
				else: txt += " ."
				mask >>= 1
			print(txt)
		print("\n")
	func print_eval(next_color):
		for y in range(N_VERT):
			var txt = ""
			var mask = 1 << 10
			for x in range(N_HORZ):
				if (h_black[y] & mask) != 0: txt += "   X"
				elif (h_white[y] & mask) != 0: txt += "   O"
				else:
					put_color(x, y, next_color)
					txt += ("%4d" % eval)
					remove_color(x, y)
				mask >>= 1
			print(txt)
		print("\n")
	func print_eval_ndiff(next_color):
		for y in range(N_VERT):
			var txt = ""
			var mask = 1 << 10
			for x in range(N_HORZ):
				if (h_black[y] & mask) != 0: txt += "    X"
				elif (h_white[y] & mask) != 0: txt += "    O"
				else:
					put_color(x, y, next_color)
					if next_color == BLACK && !is_legal_put(x, y, BLACK):
						txt += "  ---"
					else:
						calc_eval_diff(next_color)
						txt += ("%5d" % eval)
					remove_color(x, y)
				mask >>= 1
			print(txt)
		print("\n")
	func unit_test():
		assert( prio_pos.size() == N_HORZ * N_VERT )
		#
		assert(xyToDrIxMask(0, 0) == [6, 0b10000000000, 11])
		assert(xyToDrIxMask(10, 10) == [6, 0b1, 11])
		assert(xyToDrIxMask(0, 1) == [5, 0b01000000000, 10])
		assert(xyToDrIxMask(9, 10) == [5, 0b1, 10])
		assert(xyToDrIxMask(0, 2) == [4, 0b00100000000, 9])
		assert(xyToDrIxMask(8, 10) == [4, 0b1, 9])
		assert(xyToDrIxMask(1, 0) == [7, 0b01000000000, 10])
		assert(xyToDrIxMask(10, 9) == [7, 0b1, 10])
		#
		assert(xyToUrIxMask(10, 0) == [6, 0b1, 11])
		assert(xyToUrIxMask(0, 10) == [6, 0b10000000000, 11])
		assert(xyToUrIxMask(9, 0) == [5, 0b1, 10])
		assert(xyToUrIxMask(0, 9) == [5, 0b01000000000, 10])
		assert(xyToUrIxMask(8, 0) == [4, 0b1, 9])
		assert(xyToUrIxMask(0, 8) == [4, 0b00100000000, 9])
		assert(xyToUrIxMask(10, 1) == [7, 0b1, 10])
		assert(xyToUrIxMask(1, 10) == [7, 0b01000000000, 10])
		assert(xyToUrIxMask(10, 2) == [8, 0b1, 9])
		#
		var rv = eval_bitmap_34(0b0011100, 0, 7)
		assert( rv[IX_B3] == 1 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0b0010100, 0, 7)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0b00110100, 0, 8)
		assert( rv[IX_B3] == 1 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0, 0b0011100, 7)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 1 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0, 0b0010100, 7)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0, 0b00110100, 8)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_W3] == 1 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W4] == 0 )
		assert( rv[IX_B42] == 0 )
		assert( rv[IX_W42] == 0 )
		rv = eval_bitmap_34(0b011110, 0, 6)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_B4] == 1 )
		assert( rv[IX_W4] == 0 )
		assert( rv[IX_B42] == 1 )
		assert( rv[IX_W42] == 0 )
		rv = eval_bitmap_34(0, 0b011110, 6)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W4] == 1 )
		assert( rv[IX_B42] == 0 )
		assert( rv[IX_W42] == 1 )
		rv = eval_bitmap_34(0b111000, 0, 6)
		assert( rv[IX_B3] == 0 )
		rv = eval_bitmap_34(0b000111, 0, 6)
		assert( rv[IX_B3] == 0 )
		rv = eval_bitmap_34(0b011100, 0, 6)
		assert( rv[IX_B3] == 1 )
		rv = eval_bitmap_34(0b101110, 0, 6)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_B4] == 1 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0, 0b101110, 6)
		assert( rv[IX_B3] == 0 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 1 )
		# 対称性チェック
		rv = eval_bitmap_34(0b011010, 0, 6)
		var ev0 = rv[IX_EV]
		assert( rv[IX_B3] == 1 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
		rv = eval_bitmap_34(0b010110, 0, 6)
		assert( rv[IX_EV] == ev0 )
		assert( rv[IX_B3] == 1 )
		assert( rv[IX_B4] == 0 )
		assert( rv[IX_W3] == 0 )
		assert( rv[IX_W4] == 0 )
	func check_hv_bitmap() -> bool:
		for y in range(N_VERT):
			for x in range(N_HORZ):
				if get_color(x, y) != get_color_v(x, y):
					return false
		#for y in range(N_VERT):
		#	var my = 1 << (10-y)
		#	for x in range(N_HORZ):
		#		var mx = 1 << (10-x)
		#		if ((h_black[y] & mx) != 0 && (v_black[x] & my) == 0 ||
		#			(h_black[y] & mx) == 0 && (v_black[x] & my) != 0):
		#			return false
		#		if ((h_white[y] & mx) != 0 && (v_white[x] & my) == 0 ||
		#			(h_white[y] & mx) == 0 && (v_white[x] & my) != 0):
		#			return false
		return true
	func check_hud_bitmap() -> bool:
		for y in range(N_VERT):
			for x in range(N_HORZ):
				var h = get_color(x, y)
				var u = get_color_u(x, y)
				if u != UNKNOWN && u != h:
					return false
				var d = get_color_d(x, y)
				if d != UNKNOWN && d != h:
					return false
		return true

func _ready():
	build_prio_pos()
	#print("prio_pos.size() = ", prio_pos.size())
	#print("prio_pos = ", prio_pos)
	pass # Replace with function body.

func _process(delta):
	pass
func build_prio_pos():
	prio_pos = [Vector2i(CX, CY)]
	for i in range(1, CX+1):
		prio_pos.push_back(Vector2i(CX, CY-i))		# 上辺中央
		prio_pos.push_back(Vector2i(CX, CY+i))		# 下辺中央
		prio_pos.push_back(Vector2i(CX-i, CY))		# 左辺中央
		prio_pos.push_back(Vector2i(CX+i, CY))		# 右辺中央
		for k in range(i-1):
			prio_pos.push_back(Vector2i(CX-k, CY-i))		# 上辺
			prio_pos.push_back(Vector2i(CX+k, CY-i))		# 上辺
			prio_pos.push_back(Vector2i(CX-k, CY+i))		# 下辺
			prio_pos.push_back(Vector2i(CX+k, CY+i))		# 下辺
			prio_pos.push_back(Vector2i(CX-i, CY-k))		# 左辺
			prio_pos.push_back(Vector2i(CX-i, CY+k))		# 左辺
			prio_pos.push_back(Vector2i(CX+i, CY-k))		# 右辺
			prio_pos.push_back(Vector2i(CX+i, CY+k))		# 右辺
		prio_pos.push_back(Vector2i(CX-i, CY-i))	# 左上
		prio_pos.push_back(Vector2i(CX+i, CY+i))	# 右下
		prio_pos.push_back(Vector2i(CX-i, CY+i))	# 左下
		prio_pos.push_back(Vector2i(CX+i, CY-i))	# 右上

