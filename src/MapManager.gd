extends Control


#
# Config
#
const inputQuit = 'ui_cancel'


#
# Init
#
onready var mapContainer = get_node('Map')
onready var tileMap = mapContainer.get_node('TileMap')
onready var cellHighlight = tileMap.get_node('CellHighlight')
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
        # TODO use a texture instead than a flat color
        var item = TextureRect.new()
        item.expand = true
        item.rect_size.x = size
        item.rect_size.y = size
        item.rect_position.x = 0.5 * size
        item.rect_position.y = (0.5 + i) * size
        contentNode.add_child(item)


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    cellHighlight.visible = player.animationPlayer.current_animation == 'Idle'
    if cellHighlight.visible:
        cellHighlight.rect_position = player.getTargetCell() * tileMap.cell_size

    #
    # Backpack stuff
    #
    var selectionNode = backpackNode.get_node('ToolSelection')
    selectionNode.rect_position.y = selectionNode.rect_size.y * player.backpackSelectedIndex

    var itemNodes = backpackNode.get_node('Content').get_children()
    for i in player.backpackSize:
        var itemNode = itemNodes[i]
        var item = Env.itemsById[player.backpackStorage.items[i]]
        var children = itemNode.get_children()

        var itemHasScene = item and item.scene
        var sceneIsAlreadyInstantiated = children.size() > 0 and children[0].filename == item.fn
        if itemHasScene and sceneIsAlreadyInstantiated:
            # everything looks already as it should
            pass
        else:
            # update stuff
            Meta.removeAllChildren(itemNode)
            if item and item.scene:
                var instance = item.scene.instance()
                Meta.callOnDescendants(instance, 'initAsInventory')
                # This is ugly, but it's needed to show seeds since they usually have z_index = -2
                instance.z_index = 2
                itemNode.add_child(instance)


#
# Input interrupts
#
func _unhandled_input(event):
    if event.is_pressed():
        if InputMap.event_is_action(event, 'ui_end'):
            var x = Meta.callOnDescendants(self, 'oneDayPasses')


#
#
#
func positionToCell(position):
    return (position / tileMap.cell_size).floor()


func getMouseCell():
    return tileMap.world_to_map(tileMap.get_local_mouse_position())


func findAtCell(cell):
    var minx = cell.x * tileMap.cell_size.x
    var maxx = minx + tileMap.cell_size.x - 1
    var miny = cell.y * tileMap.cell_size.y
    var maxy = miny + tileMap.cell_size.y - 1

    var r = []
    for n in ySort.get_children():
        if minx <= n.position.x and n.position.x <= maxx and miny <= n.position.y and n.position.y <= maxy:
            r.append(n)

    return r


func getCellTileName(position):
    return tileMap.tile_set.tile_get_name(tileMap.get_cellv(position))


#
#
#
func spawnDrop(position, type):
    var itemScene = Env.itemsById[type].scene
    assert(itemScene)
    var drop = itemScene.instance()
    drop.position = position
    drop.type = type
    ySort.add_child(drop)


#
#
#
func hoeHitsGround(position):
    match getCellTileName(position):
        'Base':
            tileMap.set_cellv(position, tileMap.tile_set.find_tile_by_name('Tilled'))
            tileMap.update_bitmask_area(position)
            mapContainer.get_node('HoeOnGround').play()
