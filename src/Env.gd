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
#
#
onready var rng = RandomNumberGenerator.new()



#
#
#
func _onready():
    rng.randomize()
