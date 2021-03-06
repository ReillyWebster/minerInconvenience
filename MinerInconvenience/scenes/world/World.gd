extends Node2D

const Player = preload("res://scenes/player/Player.tscn")
const ExitPoint = preload("res://scenes/exit/Exit.tscn")
const OreVein = preload("res://scenes/oreVein/OreVein.tscn")
const HUD = preload("res://scenes/hud/HUD.tscn")
const PauseScreen = preload("res://scenes/pauseMenu/PauseMenu.tscn")

var borders = Rect2(1, 1, 38, 21)
var number_of_random_veins = 10
var player
var exit
var map
var player_can_exit = false

onready var tileMap = $TileMap
onready var ySort = $YSort
onready var maskView
onready var hUD = $HUD
onready var miningAudio = $MiningAudio
onready var backgroundAudio = $BackgroundAudio

# Called when the node enters the scene tree for the first time.
func _ready():
#	ySort = get_node("MainView/Viewport/YSort")
#	tileMap = get_node("MainView/Viewport/TileMap")
	
	player = Player.instance()
	ySort.add_child(player)
	
	exit = ExitPoint.instance()
	ySort.add_child(exit)
	
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19, 10), borders)
	map = walker.walk(300)
	
	player.position = map.front() * 32
	
	walker.queue_free()
	
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	var exit_position = Vector2()
	for map_position in map:
		map_position.y -= 1
		var second_step = map_position
		second_step.y -= 1 
		if tileMap.get_cellv(map_position) != tileMap.INVALID_CELL and tileMap.get_cellv(second_step) != tileMap.INVALID_CELL:
			tileMap.set_cellv(map_position, 1)
			exit_position = map_position
			pass
	
	exit.position = exit_position * 32
	exit.connect("player_in_exit_zone", self, "_on_Player_in_exit")
	exit.connect("player_left_exit_zone", self, "_on_Player_left_exit")
	
	
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
		new_vein.connect("vein_hit", self, "_on_Vein_hit")

func _on_Player_in_exit():
	player_can_exit = true

func _on_Player_left_exit():
	player_can_exit = false

func _on_Vein_hit(vein_type):
	print("Hit a " + str(vein_type) + " vein!")
	
	if vein_type:
		update_pyrite(1)
	else:
		update_gold(1)
	update_stamina(-1)
	

#TEST CONTROLS
func _input(event):
	if event.is_action_pressed("ui_menu"):
		var pauseScreen = PauseScreen.instance()
		$HUD.add_child(pauseScreen)
		get_tree().paused = true
	if event.is_action_pressed("ui_focus_next"):
		hUD.update_stamina(-1)
	if event.is_action_pressed("ui_accept") and player_can_exit:
		exit_level()	

func exit_level():
	if Global.current_pyrite >= Global.exit_cost:
		update_pyrite(-Global.exit_cost)
		Global.current_stage += 1
		if Global.current_stage == 0:
			get_tree().change_scene("res://scenes/victoryScreen/VictoryScreen.tscn")
		else:
			Global.exit_cost = ceil((Global.current_stage + 11)/2)
			hUD.update_stage_counter()
			get_tree().reload_current_scene()

func update_gold(value):
	Global.current_gold += value
	hUD.update_gold()

func update_pyrite(value):
	Global.current_pyrite += value
	hUD.update_pyrite()

func update_stamina(value):
	Global.current_stamina += value
	hUD.update_stamina()
	if Global.current_stamina <= 0:
		get_tree().change_scene("res://scenes/gameover/GameOver.tscn")

