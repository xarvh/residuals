extends Control


const Drop = preload('res://scenes/drop/Drop.tscn')


#
# Config
#
const inputQuit = 'ui_cancel'

const inputNextTool = 'SelectNextTool'
const inputPrevTool = 'SelectPrevTool'

const toolSelectionSize = 10


#
# Init
#
onready var mapContainer = get_node('Map')
onready var tilemap = mapContainer.get_node('TileMap')
onready var cellHighlight = tilemap.get_node('CellHighlight')
onready var ySort = mapContainer.get_node('YSort')
onready var player = ySort.get_node('Player')

# TODO stuff that should probably be in some other module

onready var toolSelection = get_node('HUD').get_node('Belt').get_node('ToolSelection')
onready var selectedToolIndex = 0


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

    toolSelection.rect_position.y = toolSelection.rect_size.y * selectedToolIndex


#
# Input interrupts
#
func _unhandled_input(event):
    if event.is_pressed():
        if InputMap.event_is_action(event, inputNextTool):
            selectedToolIndex = (selectedToolIndex + 1) % toolSelectionSize

        if InputMap.event_is_action(event, inputPrevTool):
            selectedToolIndex = ((selectedToolIndex + toolSelectionSize - 1) % toolSelectionSize)


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


#
#
#
func spawnDrop(position, type):
    var drop = Drop.instance()
    drop.position = position
    drop.type = type
    ySort.add_child(drop)
