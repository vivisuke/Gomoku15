extends Node2D

var bd

# Called when the node enters the scene tree for the first time.
func _ready():
	bd = g.Board.new()
	$Board/TileMap.set_cell(0, Vector2i(0, 0), -1)
	$Board/TileMap.set_cell(0, Vector2i(0, 2), 0, Vector2i(0, 0), 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
