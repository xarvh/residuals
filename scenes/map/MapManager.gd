extends Control


const Drop = preload('res://scenes/drop/Drop.tscn')


#
# Config
#
const inputQuit = 'ui_cancel'


#
# Init
#
onready var mapContainer = get_node('Map')
onready var tilemap = mapContainer.get_node('TileMap')
onready var cellHighlight = tilemap.get_node('CellHighlight')
onready var ySort = mapContainer.get_node('YSort')
onready var player = ySort.get_node('Player')


#
# Backpack
#
onready var backpackNode = get_node('HUD/Backpack')


func _ready():
    cellHighlight.visible = false

    #
    # Backpack stuff
    #
    var size = backpackNode.rect_size.x
    var contentNode = backpackNode.get_node('Content')
    for i in player.backpackSize:
        var item = TextureRect.new()
        item.expand = true
        item.rect_size.x = size
        item.rect_size.y = size
        item.rect_position.y = i * size
        contentNode.add_child(item)


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
    # Backpack stuff
    #
    var selectionNode = backpackNode.get_node('ToolSelection')
    selectionNode.rect_position.y = selectionNode.rect_size.y * player.backpackSelectedIndex

    var itemNodes = backpackNode.get_node('Content').get_children()
    for i in player.backpackSize:
        var itemNode = itemNodes[i]
        var texture = itemToTexture(player.backpackStorage.items[i])
        # let's check just in case the assignment does some magic
        if itemNode.texture != texture:
            itemNode.texture = texture


#
# TODO move this somewhere else
#
# TODO Ideally, the info should also contain offset and material, so maybe load a Scene instead?
# It's actually one Scene for the backpack selector and one Scene for the player sprite?
#
# TODO Also add info on how the item is held
#
func itemToTexture(item):
    match item:
        null:
            return null

        Env.Item.Axe:
            return load('res://scenes/human/axe.png')

        Env.Item.Pickaxe:
            return load('res://scenes/human/pickaxe.png')

        Env.Item.Wood:
            return load('res://scenes/drop/wood.png')


#
# Input interrupts
#
func _unhandled_input(event):
    pass


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
