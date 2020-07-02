extends Node2D


#
#
#
const cellSize = 8


enum Item {
    Axe
    Pickaxe
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
