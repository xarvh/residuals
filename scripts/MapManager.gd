extends Node2D


#
# Config
#

const inputQuit = "ui_cancel"



#
# Init
#
onready var tilemap = get_node('TileMap')
onready var cellHighlight = tilemap.get_node('CellHighlight')
onready var ySort = get_node('YSort')
onready var player = ySort.get_node('Player')

onready var toolTargetCell = null


func _ready():
    cellHighlight.visible = false


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    cellHighlight.visible = player.animation_player.current_animation == 'Idle'
    if cellHighlight.visible:
        cellHighlight.rect_position = getTargetCell() * tilemap.cell_size


func playerToolSwingStart():
    toolTargetCell = getTargetCell()
    return (toolTargetCell + Vector2(0.5, 0.5)) * tilemap.cell_size


func playerToolSwingHit():
    print("hit: ", toolTargetCell)


#
#
#
func getPlayerCell():
    return (player.position / tilemap.cell_size).floor()

func getTargetCell():
    var mouse_cell = tilemap.world_to_map(tilemap.get_local_mouse_position())
    var player_cell = getPlayerCell()
    return (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell

