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
onready var ySort = self.get_node('YSort')
onready var player = ySort.get_node('Player')

onready var toolTargetCell = null



func _ready():
    self.cellHighlight.visible = false


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    var mouse_cell = self.tilemap.world_to_map(self.tilemap.get_local_mouse_position())
    var cell_size = self.tilemap.cell_size
    var player_cell = (self.player.position / cell_size).floor()
    var selected_cell = (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell

#    self.cellHighlight.visible = self.player.animation_player.current_animation == 'Idle'
#    if self.cellHighlight.visible:
#        self.cellHighlight.rect_position = selected_cell * cell_size


func playerToolSwingStart():
    print("playerToolSwingStart!!!!")


func playerToolSwingHit():
    print("playerToolSwingHit@@@@@@@@@")
