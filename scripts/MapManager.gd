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
    var targets = findAtCell(toolTargetCell))


#
#
#
func getPlayerCell():
    return (player.position / tilemap.cell_size).floor()

func getTargetCell():
    var mouse_cell = tilemap.world_to_map(tilemap.get_local_mouse_position())
    var player_cell = getPlayerCell()
    return (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell


func findAtCell(cell):
    var minx = cell.x * tilemap.cell_size.x
    var maxx = minx + tilemap.cell_size.x - 1
    var miny = cell.y * tilemap.cell_size.y
    var maxy = miny + tilemap.cell_size.y - 1

    var r = []
    for n in ySort.get_children():
        if minx <= n.position.x and n.position.x <= maxx and miny <= n.position.y and n.position.y <= maxy:
              r.append(n)

    return r
