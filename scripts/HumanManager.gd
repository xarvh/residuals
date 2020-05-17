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
# internals
#
var tilemap
var cellHighlight
var sprite
var animation_player

func _ready():
    self.tilemap = self.get_node('TileMap')
    self.cellHighlight = self.tilemap.get_node('CellHighlight')
    self.cellHighlight.visible = false
    self.sprite = self.get_node('HumanCharacter')
    self.animation_player = self.sprite.get_node("AnimationPlayer")


#
#
#
func _unhandled_input(event):

    if event.is_pressed() and InputMap.event_is_action(event, inputUseTool):
        self.cellHighlight.visible = true




#
#
#
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    var animation = self.animation_player.current_animation

    if animation == "SwingTool":
      return


    if self.cellHighlight.visible:
      self.cellHighlight.rect_position = self.tilemap.world_to_map(self.tilemap.get_local_mouse_position()) * self.tilemap.cell_size



    if Input.is_action_just_released(inputUseTool):
        self.cellHighlight.visible = false
        if animation == "Idle" or animation == "Walk":
          self.animation_player.play("SwingTool")
          return








    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    if dx or dy:
        var n = sqrt(dx * dx + dy * dy)
        move(dx / n, dy / n, delta)
    else:
        stand(delta)


func move(dx, dy, delta):
    self.sprite.position.x += dx * delta * walkingSpeed
    self.sprite.position.y += dy * delta * walkingSpeed

    self.animation_player.play("Walk")

    if dx < 0: self.sprite.scale.x = -1
    if dx > 0: self.sprite.scale.x = 1


func stand(delta):
    self.animation_player.play("Idle")
