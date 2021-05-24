extends Node2D

const Player = preload("res://Player.tscn")

var borders = Rect2(1, 1, 38, 21)

onready var tileMap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19, 10), borders)
	var map = walker.walk(500)
	
	var player = Player.instance()
	add_child(player)
	player.position = map.front() * 32
	
	walker.queue_free()
	
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass