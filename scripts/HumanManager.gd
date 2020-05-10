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
var sprite
var animation_player

func _ready():
    self.sprite = self.get_node('HumanCharacter')
    self.animation_player = self.sprite.get_node("AnimationPlayer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

    if Input.is_action_just_pressed(inputQuit):
        get_tree().quit()

    var a = self.animation_player.current_animation

    if a == "SwingTool":
      return

    if Input.is_action_just_pressed(inputUseTool):
        if a == "Idle" or a == "Walk":
          var x = self.animation_player.play("SwingTool")
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
