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


func _ready():
    cellHighlight.visible = false


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    cellHighlight.visible = player.animationPlayer.current_animation == 'Idle'
    if cellHighlight.visible:
        cellHighlight.rect_position = player.getTargetCell() * tilemap.cell_size


#
#
#
func positionToCell(position):
    return (position / tilemap.cell_size).floor()


func getMouseCell():
    return tilemap.world_to_map(tilemap.get_local_mouse_position())


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
