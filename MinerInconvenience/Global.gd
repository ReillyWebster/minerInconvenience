extends Node


var exit_cost = 1
var current_gold = 0
var current_pyrite = 0
var max_stamina = 30
var current_stamina = max_stamina
var current_stage = -10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func restart():
	exit_cost = 1
	current_gold = 0
	current_pyrite = 0
	max_stamina = 30
	current_stamina = max_stamina
	current_stage = -10
	get_tree().change_scene("res://scenes/startingZone/StartingZone.tscn")
