extends Node2D


#
#
#
const cellSize = 8


enum Item {
    Axe
    Pickaxe
    Hoe
    Wood
}


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

        Env.Item.Hoe:
            return load('res://scenes/human/hoe.png')

        Env.Item.Wood:
            return load('res://scenes/drop/wood.png')


#
#
#
onready var rng = RandomNumberGenerator.new()



#
#
#
func _onready():
    rng.randomize()
