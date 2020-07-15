extends Node2D


#
#
#
const cellSize = 8


enum ItemId {
    Interact
    Axe
    Pickaxe
    Hoe
    Wood
    CauliflowerSeeds
}


enum ItemUse {
    Interact
    Swing
    Place
}


onready var itemsById = _makeItemsById([{
    id = null,
    fn = null,
    use = null,
}, {
    id = ItemId.Interact,
    fn = null,
    use = ItemUse.Interact,
}, {
    id = ItemId.Axe,
    fn = 'res://scenes/tools/axe.tscn',
    use = ItemUse.Swing,
}, {
    id = ItemId.Pickaxe,
    fn = 'res://scenes/tools/pickaxe.tscn',
    use = ItemUse.Swing,
}, {
    id = ItemId.Hoe,
    fn = 'res://scenes/tools/hoe.tscn',
    use = ItemUse.Swing,
}, {
    id = ItemId.Wood,
    fn = 'res://scenes/drops/wood.tscn',
    use = null,
}, {
    id = ItemId.CauliflowerSeeds,
    fn = 'res://scenes/plants/cauliflower.tscn',
    use = ItemUse.Place,
}])


func _makeItemsById(items):
    var dict = {}

    for item in items:
        dict[item.id] = item

        item.scene = load(item.fn) if item.fn else null

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
