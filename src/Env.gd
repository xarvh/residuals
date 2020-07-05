extends Node2D


#
#
#
const cellSize = 8


enum ItemId {
    Axe
    Pickaxe
    Hoe
    Wood
}


onready var itemsById = _makeItemsById([{
    id = null,
    path = null,
    canSwing = false,
}, {
    id = ItemId.Axe,
    path = 'res://scenes/human/axe.png',
    canSwing = true,
}, {
    id = ItemId.Pickaxe,
    path = 'res://scenes/human/pickaxe.png',
    canSwing = true,
}, {
    id = ItemId.Hoe,
    path = 'res://scenes/human/hoe.png',
    canSwing = true,
}, {
    id = ItemId.Wood,
    path = 'res://scenes/drop/wood.png',
    canSwing = false,
}])


func _makeItemsById(items):
    var dict = {}

    for item in items:
        dict[item.id] = item

        # TODO Ideally, the info should also contain offset and material, so maybe load a Scene instead?
        # It's actually one Scene for the backpack selector and one Scene for the player sprite?
        item.texture = load(item.path) if item.path else null

    return dict


#
#
#
onready var rng = RandomNumberGenerator.new()



#
#
#
func _onready():
    rng.randomize()
