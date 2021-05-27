extends Node2D

const Player = preload("res://scenes/player/Player.tscn")
const ExitPoint = preload("res://scenes/exit/Exit.tscn")
const OreVein = preload("res://scenes/oreVein/OreVein.tscn")

var borders = Rect2(1, 1, 38, 21)
var number_of_random_veins = 10

onready var tileMap = $TileMap
onready var ySort = $YSort

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19, 10), borders)
	var map = walker.walk(200)
	
	var player = Player.instance()
	ySort.add_child(player)
	player.position = map.front() * 32
	
	var exit = ExitPoint.instance()
	ySort.add_child(exit)
	exit.position = map.back() * 32
	
	
	walker.queue_free()
	
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	for map_position in map:
		map_position.y -= 1
		var second_step = map_position
		second_step.y -= 1 
		if tileMap.get_cellv(map_position) != tileMap.INVALID_CELL and tileMap.get_cellv(second_step) != tileMap.INVALID_CELL:
			print ("Tile at x" + str(map_position.x) + " y" + str(map_position.y))
			tileMap.set_cellv(map_position, 1)
			pass
	
	var new_veins = map.duplicate()
	new_veins.pop_front()
	new_veins.pop_back()
	
	for deploy_vein in number_of_random_veins:
		var map_position = randi() % new_veins.size()
		var vein_position = new_veins[map_position] * 32
		while vein_position == player.position or vein_position == exit.position:
			map_position = randi() % new_veins.size()
			vein_position = new_veins[map_position] * 32
		var new_vein = OreVein.instance()
		ySort.add_child(new_vein)
		new_vein.position = vein_position
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
