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

func _ready():
    self.tilemap = self.get_node('TileMap')
    self.cellHighlight = self.tilemap.get_node('CellHighlight')

    var ySort = self.get_node('YSort')
    self.player = ySort.get_node('HumanCharacter')
    self.animation_player = self.player.get_node("AnimationPlayer")

    self.cellHighlight.visible = false
    self.animation_player.connect("animation_finished", self, "_on_animation_finished")


#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    # TODO: allow use of dx dy
    if self.cellHighlight.visible:
      self.cellHighlight.rect_position = self.tilemap.world_to_map(self.tilemap.get_local_mouse_position()) * self.tilemap.cell_size

    self.cellHighlight.visible = self.animation_player.current_animation == "RaiseTool"

    match self.animation_player.current_animation:
        "Idle":
            walk_or_idle(dx, dy, delta)

        "Walk":
            walk_or_idle(dx, dy, delta)

        "RaiseTool":
            # TODO allow cancelling the swing, going back to Idle
            if Input.is_action_just_released(inputUseTool):
                self.animation_player.play("SwingTool")

        "SwingTool":
            pass

        _:
          self.animation_player.play("Idle")


func _unhandled_input(event):
    match self.animation_player.current_animation:
        "Idle":
            if event.is_pressed() and InputMap.event_is_action(event, inputUseTool):
                self.animation_player.play("RaiseTool")
                self.cellHighlight.visible = true


func _on_animation_finished(name):
    match name:
        "SwingTool":
            # TODO apply tool effect
            pass


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
