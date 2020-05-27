extends Node2D


#
# Config
#
const inputUp = "ui_up"
const inputDown = "ui_down"
const inputLeft = "ui_left"
const inputRight = "ui_right"
const inputUseTool = "ui_accept"
const inputQuit = "ui_cancel"

const walkingSpeed = 10


#
# Init
#
var tilemap
var cellHighlight
var player
var animation_player
var toolTargetCell

func _ready():
    self.tilemap = self.get_node('TileMap')
    self.cellHighlight = self.tilemap.get_node('CellHighlight')

    var ySort = self.get_node('YSort')
    self.player = ySort.get_node('HumanCharacter')
    self.animation_player = self.player.get_node("AnimationPlayer")

    self.cellHighlight.visible = false
    self.toolTargetCell = null
    self.animation_player.connect("animation_finished", self, "_onAnimationFinished")
    self.animation_player.connect("signalSwingHit", self, "_onSignalSwingHit")


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    var mouse_cell = self.tilemap.world_to_map(self.tilemap.get_local_mouse_position())
    var cell_size = self.tilemap.cell_size
    var player_cell = (self.player.position / cell_size).floor()
    var selected_cell = (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell

    self.cellHighlight.visible = self.animation_player.current_animation == 'Idle'
    if self.cellHighlight.visible:
        self.cellHighlight.rect_position = selected_cell * cell_size

    match self.animation_player.current_animation:
        "Idle":
            if Input.is_action_pressed(inputUseTool):
                # TODO turn towards target cell
                self.animation_player.play("SwingTool")
                self.toolTargetCell = selected_cell
            else:
                walk_or_idle(dx, dy, delta)

        "Walk":
            walk_or_idle(dx, dy, delta)

        "SwingTool":
            pass

        _:
          self.animation_player.play("Idle")


func _unhandled_input(event):
    match self.animation_player.current_animation:
        "Idle":
            if event.is_pressed() and InputMap.event_is_action(event, inputUseTool):
                pass


func _onAnimationFinished(name):
    match name:
        "SwingTool":
            pass


func _onSignalSwingHit():
    print('doing stuff to cell', self.toolTargetCell)



func walk_or_idle(dx, dy, delta):
    if dx or dy:
        var n = sqrt(dx * dx + dy * dy)

        self.player.position.x += dx / n * delta * walkingSpeed
        self.player.position.y += dy / n * delta * walkingSpeed

        self.animation_player.play("Walk")

        if dx < 0: self.player.scale.x = -1
        if dx > 0: self.player.scale.x = 1

    else:
        self.animation_player.play("Idle")
