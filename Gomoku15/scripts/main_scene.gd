extends Node2D

var N_HORZ = g.N_HORZ
var bd

# Called when the node enters the scene tree for the first time.
func _ready():
	bd = g.Board.new()
	$Board/TileMap.set_cell(0, Vector2i(0, 0), -1)
	$Board/TileMap.set_cell(0, Vector2i(0, 2), 0, Vector2i(0, 0), 0)
	unit_test()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func unit_test():
	var b2 = g.Board.new()
	# テスト：is_five()
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 0, g.BLACK)
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	print("h_black[0] = %03x" % b2.h_black[0])
	print("five" if b2.is_five(4, 0, g.BLACK) else "NOT five")
	assert(b2.is_five(4, 0, g.BLACK))
	b2.clear()
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 1, g.BLACK)
	b2.put_color(2, 2, g.BLACK)
	b2.put_color(3, 3, g.BLACK)
	b2.put_color(4, 4, g.BLACK)
	assert(b2.is_five(4, 4, g.BLACK))
	b2.clear()
	b2.put_color(10, 0, g.BLACK)
	assert(b2.u_black[6] == 0x001)
	b2.put_color(9, 1, g.BLACK)
	b2.put_color(8, 2, g.BLACK)
	b2.put_color(7, 3, g.BLACK)
	b2.put_color(6, 4, g.BLACK)
	print("u_black[5] = %03x" % b2.u_black[5])
	assert(b2.is_five(6, 4, g.BLACK))
	# テスト：is_six(x, y, col) 
	b2.clear()
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 0, g.BLACK)
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	b2.put_color(5, 0, g.BLACK)
	assert( b2.is_six(3, 0, g.BLACK) )
	b2.remove_color(2, 0)
	b2.put_color(2, 0, g.WHITE)
	assert( !b2.is_six(3, 0, g.BLACK) )
	# テスト：is_four(x, y, col) 
	b2.clear()
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 0, g.BLACK)
	b2.put_color(2, 0, g.BLACK)
	assert( !b2.is_four(2, 0, g.BLACK) )	# 三の場合
	b2.put_color(3, 0, g.BLACK)
	assert( b2.is_four(3, 0, g.BLACK) )		# （連続）四の場合
	b2.put_color(4, 0, g.WHITE)
	assert( !b2.is_four(4, 0, g.BLACK) )	# 四が止められているの場合
	b2.remove_color(3, 0)
	b2.remove_color(4, 0)
	b2.put_color(4, 0, g.BLACK)
	assert( b2.is_four(4, 0, g.BLACK) )		# 飛び四 の場合
	b2.clear()
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 1, g.BLACK)
	b2.put_color(2, 2, g.BLACK)
	assert( !b2.is_four(2, 2, g.BLACK) )	# 三の場合
	b2.put_color(3, 3, g.BLACK)
	assert( b2.is_four(3, 3, g.BLACK) )		# （連続）四の場合
	b2.remove_color(3, 3)
	b2.put_color(4, 4, g.BLACK)
	assert( b2.is_four(4, 4, g.BLACK) )		# 飛び四 の場合
	b2.clear()
	b2.put_color(0, 0, g.WHITE)
	b2.put_color(1, 1, g.BLACK)
	b2.put_color(2, 2, g.BLACK)
	b2.put_color(3, 3, g.BLACK)
	b2.put_color(4, 4, g.BLACK)
	assert( b2.is_four(1, 1, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(2, 2, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(3, 3, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(4, 4, g.BLACK) )		# （連続）四の場合
	b2.put_color(1, (N_HORZ-4), g.BLACK)				# ｜・●●●●｜
	b2.put_color(2, (N_HORZ-3), g.BLACK)
	b2.put_color(3, (N_HORZ-2), g.BLACK)
	b2.put_color(4, (N_HORZ-1), g.BLACK)
	assert( b2.is_four(1, (N_HORZ-4), g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(2, (N_HORZ-3), g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(3, (N_HORZ-2), g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(4, (N_HORZ-1), g.BLACK) )		# （連続）四の場合
	b2.put_color(0, 6, g.WHITE)					# ｜◯●●●●｜
	assert( !b2.is_four(1, 7, g.BLACK) )		# 四が止められているの場合
	assert( !b2.is_four(2, 8, g.BLACK) )		# 四が止められているの場合
	assert( !b2.is_four(3, 9, g.BLACK) )		# 四が止められているの場合
	assert( !b2.is_four(4, 10, g.BLACK) )		# 四が止められているの場合
	b2.put_color(0, 5, g.WHITE)					# ｜◯●●●●・｜
	b2.put_color(1, 6, g.BLACK)
	b2.put_color(2, 7, g.BLACK)
	b2.put_color(3, 8, g.BLACK)
	b2.put_color(4, 9, g.BLACK)
	assert( b2.is_four(1, 6, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(2, 7, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(3, 8, g.BLACK) )		# （連続）四の場合
	assert( b2.is_four(4, 9, g.BLACK) )		# （連続）四の場合
	# テスト：is_three(x, y, col) 
	b2.clear()
	b2.put_color(1, 0, g.BLACK)
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)				# ｜・●●●・・…｜
	assert( b2.is_three(1, 0, g.BLACK) )	# 三の場合
	assert( b2.is_three(2, 0, g.BLACK) )	# 三の場合
	assert( b2.is_three(3, 0, g.BLACK) )	# 三の場合
	b2.put_color(5, 0, g.WHITE)				# ｜・●●●・◯…｜
	assert( !b2.is_three(1, 0, g.BLACK) )	# 非活三の場合
	assert( !b2.is_three(2, 0, g.BLACK) )	# 非活三の場合
	assert( !b2.is_three(3, 0, g.BLACK) )	# 非活三の場合
	b2.remove_color(3, 0)
	b2.remove_color(5, 0)
	b2.put_color(4, 0, g.BLACK)				# ｜・●●・●・…｜
	assert( b2.is_three(1, 0, g.BLACK) )	# 飛び三の場合
	assert( b2.is_three(2, 0, g.BLACK) )	# 飛び三の場合
	assert( b2.is_three(4, 0, g.BLACK) )	# 飛び三の場合
	b2.put_color(0, 0, g.WHITE)				# ｜◯●●・●・…｜
	assert( !b2.is_three(1, 0, g.BLACK) )	# 飛び三の場合
	assert( !b2.is_three(2, 0, g.BLACK) )	# 飛び三の場合
	assert( !b2.is_three(4, 0, g.BLACK) )	# 飛び三の場合
	# 問題：｜・●●●◯ が高評価されてしまう？
	b2.clear()
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 1, g.BLACK)
	b2.put_color(4, 2, g.BLACK)
	b2.put_color(5, 3, g.BLACK)
	b2.put_color(6, 4, g.WHITE)
	b2.calc_eval_diff(g.WHITE)
	print("calc_eval_diff(): ", b2.eval)
	#var t = b2.eval_bitmap(b2.d_black[8], b2.d_white[8], 9, g.WHITE)
	#print("eval_bitmap(): ", t)
	#
	##b2.verbose = true
	##var ev1101 = b2.eval_bitmap(0b00011010000, 0, 11, g.BLACK)
	##var ev1011 = b2.eval_bitmap(0b00001011000, 0, 11, g.BLACK)
	##b2.verbose = false
	##assert( ev1101 == ev1011 )
	#var ev1011 = b2.eval_bitmap(0b000000110, 0, 11, g.BLACK)
	#
	b2.clear()
	b2.calc_eval_diff(g.BLACK)
	assert(b2.eval == 0)
	b2.put_color(0, 0, g.BLACK)
	assert(b2.d_black[6] == 0b10000000000)
	b2.calc_eval_diff(g.WHITE)
	print(b2.eval)
	assert(b2.eval == 3)
	# 合法手チェック
	b2.clear()
	b2.put_color(1, 0, g.BLACK)
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	b2.put_color(5, 0, g.BLACK)
	b2.put_color(6, 0, g.BLACK)				# ｜・●●●●●●・…｜
	assert( !b2.is_legal_put(1, 0, g.BLACK) )
	assert( !b2.is_legal_put(2, 0, g.BLACK) )
	assert( !b2.is_legal_put(3, 0, g.BLACK) )
	assert( !b2.is_legal_put(4, 0, g.BLACK) )
	assert( !b2.is_legal_put(5, 0, g.BLACK) )
	assert( !b2.is_legal_put(6, 0, g.BLACK) )
	b2.clear()
	b2.put_color(0, 4, g.WHITE)
	b2.put_color(1, 4, g.BLACK)
	b2.put_color(2, 4, g.BLACK)
	b2.put_color(3, 4, g.BLACK)
	b2.put_color(4, 3, g.BLACK)
	b2.put_color(4, 5, g.BLACK)
	b2.put_color(4, 4, g.BLACK)		
	assert( b2.is_legal_put(4, 4, g.BLACK) )	# 四三
	b2.put_color(4, 6, g.BLACK)
	assert( !b2.is_legal_put(4, 4, g.BLACK) )	# 四四
	b2.clear()
	b2.put_color(3, 4, g.BLACK)
	b2.put_color(5, 4, g.BLACK)
	b2.put_color(4, 3, g.BLACK)
	b2.put_color(4, 5, g.BLACK)
	b2.put_color(4, 4, g.BLACK)		
	assert( !b2.is_legal_put(4, 4, g.BLACK) )	# 三三
	b2.put_color(2, 4, g.WHITE)
	assert( b2.is_legal_put(4, 4, g.BLACK) )	# 横方向が 非活三
	#
	b2.clear()
	assert(b2.eval == 0)
	b2.print_eval_ndiff(g.BLACK)
	print("eval = ", b2.eval)
	b2.put_color(4, 4, g.BLACK)
	print("eval = ", b2.eval)
	b2.put_color(5, 5, g.WHITE)
	b2.put_color(5, 4, g.BLACK)
	b2.put_color(6, 4, g.WHITE)
	b2.put_color(4, 5, g.BLACK)
	b2.put_color(4, 6, g.WHITE)
	b2.print_eval_ndiff(g.BLACK)
	print("eval = ", b2.eval)
	# 評価値対称性チェック
	if false:
		b2.clear()
		b2.put_color(5, 4, g.BLACK)
		b2.put_color(5, 6, g.BLACK)
		b2.put_color(4, 5, g.BLACK)
		b2.put_color(6, 5, g.BLACK)
		b2.put_color(0, 0, g.WHITE)
		b2.put_color(10, 0, g.WHITE)
		b2.put_color(0, 10, g.WHITE)
		b2.put_color(10, 10, g.WHITE)
		var ev0 = b2.eval
		b2.put_color(5, 3, g.BLACK)
		b2.print()
		var ev02 = b2.eval
		#    ４５６７
		#  ３・●・・
		#  ４・●・・
		#  ５●・●・
		#  ６・●・・
		#  ７・・・・
		var evu = b2.calc_eval_diff(g.WHITE)
		b2.remove_color(5, 3)
		assert( b2.eval == ev0 )
		b2.put_color(5, 7, g.BLACK)
		b2.print()
		assert( b2.eval == ev02 )
		#    ４５６７
		#  ３・・・・
		#  ４・●・・
		#  ５●・●・
		#  ６・●・・
		#  ７・●・・
		var evd = b2.calc_eval_diff(g.WHITE)
		b2.remove_color(5, 7)
		assert( evu == evd )
	# 黒白三・四数チェック
	b2.clear()
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.put_color(0, 0, g.BLACK)
	b2.put_color(1, 0, g.BLACK)
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.put_color(2, 0, g.BLACK)			# ｜●●●・・…
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.put_color(0, 1, g.WHITE)
	b2.put_color(0, 2, g.WHITE)
	b2.put_color(0, 3, g.WHITE)
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.clear()
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	assert( b2.n_black_three == 1 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.clear()
	b2.put_color(3, 3, g.BLACK)
	b2.put_color(4, 4, g.BLACK)
	b2.put_color(6, 6, g.BLACK)
	b2.put_color(7, 7, g.BLACK)			# ｜・・・●●・●●・・…
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 1 )
	assert( b2.n_white_four == 0 )
	b2.clear()
	b2.put_color(3, 3, g.BLACK)
	b2.put_color(4, 4, g.BLACK)
	b2.put_color(5, 5, g.BLACK)
	b2.put_color(7, 7, g.BLACK)			# ｜・・・●●●・●・・…
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 1 )
	assert( b2.n_white_four == 0 )
	b2.clear()
	b2.put_color(3, 3, g.BLACK)
	b2.put_color(5, 5, g.BLACK)
	b2.put_color(6, 6, g.BLACK)			# ｜・・・●・●●・・…
	assert( b2.n_black_three == 1 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 0 )
	assert( b2.n_white_four == 0 )
	b2.put_color(7, 7, g.BLACK)			# ｜・・・●・●●●・・…
	assert( b2.n_black_three == 0 )
	assert( b2.n_white_three == 0 )
	assert( b2.n_black_four == 1 )
	assert( b2.n_white_four == 0 )
	# 評価関数差分計算
	b2.clear()
	assert( b2.eval == 0 )
	b2.put_color(0, 0, g.BLACK)
	print("eval = ", b2.eval)
	print("h_eval[0] = ", b2.h_eval[0])
	print("h_eval[1] = ", b2.h_eval[1])
	print("v_eval[0] = ", b2.v_eval[0])
	print("d_eval[6] = ", b2.d_eval[6])
	print("d_eval[5] = ", b2.d_eval[5])
	assert( b2.calc_eval_diff(g.WHITE) > 0 )
	b2.put_color(0, 1, g.WHITE)
	print("eval = ", b2.eval)
	print("h_eval[0] = ", b2.h_eval[0])
	print("h_eval[1] = ", b2.h_eval[1])
	print("v_eval[0] = ", b2.v_eval[0])
	print("d_eval[6] = ", b2.d_eval[6])
	print("d_eval[5] = ", b2.d_eval[5])
	assert( b2.calc_eval_diff(g.BLACK) < 0 )		# 白の方が中央にあり、黒は端っこ
	b2.put_color(1, 0, g.BLACK)
	print("eval = ", b2.eval)
	assert( b2.calc_eval_diff(g.WHITE) > 0 )
	b2.put_color(1, 1, g.WHITE)
	print("eval = ", b2.eval)
	assert( b2.calc_eval_diff(g.BLACK) < 0 )		# 白の方が中央にあり、黒は端っこ
	b2.put_color(2, 0, g.BLACK)
	print("eval = ", b2.eval)
	assert( b2.calc_eval_diff(g.WHITE) > 0 )
	b2.put_color(2, 1, g.WHITE)
	print("eval = ", b2.eval)
	print("n_black_three = ", b2.n_black_three)
	print("n_white_three = ", b2.n_white_three)
	print("n_black_four = ", b2.n_black_four)
	print("n_white_four = ", b2.n_white_four)
	assert( b2.calc_eval_diff(g.BLACK) < 0 )		# 白の方が中央にあり、黒は端っこ
	b2.put_color(3, 0, g.BLACK)
	print("eval = ", b2.eval)
	assert( b2.calc_eval_diff(g.WHITE) > 0 )
	b2.put_color(3, 1, g.WHITE)
	print("n_black_four = ", b2.n_black_four)
	print("n_white_four = ", b2.n_white_four)
	print("eval = ", b2.eval)
	assert( b2.calc_eval_diff(g.BLACK) > 0 )		# 次の手番の黒に四が出来ている
	b2.clear()
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	b2.put_color(2, 1, g.WHITE)
	b2.put_color(3, 1, g.WHITE)
	b2.put_color(4, 1, g.WHITE)
	print("eval = ", b2.eval)
	print("n_black_three = ", b2.n_black_three)
	print("n_white_three = ", b2.n_white_three)
	print("n_black_four = ", b2.n_black_four)
	print("n_white_four = ", b2.n_white_four)
	assert( b2.calc_eval_diff(g.BLACK) > 0 )		# 次の手番の黒に三が出来ている
	## 黒五だ出来た時点で終局なので、このような状況はありあえない
	##b2.clear()
	##b2.put_color(0, 0, g.BLACK)
	##b2.put_color(1, 0, g.BLACK)
	##b2.put_color(2, 0, g.BLACK)
	##b2.put_color(3, 0, g.BLACK)
	##b2.put_color(4, 0, g.BLACK)		# 黒：五が出来ている
	##b2.put_color(0, 1, g.WHITE)
	##b2.put_color(1, 1, g.WHITE)
	##b2.put_color(2, 1, g.WHITE)
	##b2.put_color(3, 1, g.WHITE)		# 白：活きている四
	#  ●●●●●
	#  ◯◯◯◯
	##assert( b2.calc_eval_diff(g.WHITE) > 1000 )		# 黒五が出来ている
	b2.clear()
	b2.put_color(2, 0, g.BLACK)
	b2.put_color(3, 0, g.BLACK)
	b2.put_color(4, 0, g.BLACK)
	b2.put_color(5, 0, g.BLACK)
	print("eval = ", b2.eval)
	var e4 = b2.calc_eval_diff(g.WHITE)
	b2.remove_color(5, 0)
	b2.put_color(6, 0, g.BLACK)
	print("eval = ", b2.eval)
	var e3_1 = b2.calc_eval_diff(g.WHITE)
	assert( e4 > e3_1 )
	b2.clear()
	b2.put_color(4, 6, g.BLACK)
	b2.put_color(5, 6, g.BLACK)
	b2.put_color(6, 6, g.BLACK)
	b2.put_color(7, 6, g.BLACK)		# 黒：両端空四
	b2.put_color(4, 4, g.WHITE)
	b2.put_color(5, 4, g.WHITE)
	b2.put_color(6, 4, g.WHITE)		# 白：両端空三
	var e4_3 = b2.calc_eval_diff(g.WHITE)
	assert( e4_3 >= 9000 )
	#
	b2.clear()
	b2.put_color(6, 3, g.BLACK)
	b2.put_color(6, 4, g.BLACK)
	b2.put_color(6, 5, g.BLACK)
	b2.put_color(7, 6, g.BLACK)
	b2.put_color(8, 6, g.BLACK)
	b2.put_color(5, 3, g.WHITE)
	b2.put_color(7, 3, g.WHITE)
	b2.put_color(4, 4, g.WHITE)
	b2.put_color(8, 4, g.WHITE)		# 黒 (6, 6) で四三
	b2.put_color(6, 2, g.WHITE)		# 四三の逆を止める
	b2.put_color(6, 6, g.BLACK)		# 黒：四三
	b2.print()
	var e34 = b2.calc_eval_diff(g.WHITE)
	print("e34 = ", e34)
	b2.put_color(6, 7, g.WHITE)		# 白：四を止める
	b2.print()
	e34 = b2.calc_eval_diff(g.BLACK)
	print("e34 = ", e34)
	#
	pass
