extends Node2D


const meta = preload('res://scripts/meta.gd')


#
# Config
#
const inputUp = "ui_up"
const inputDown = "ui_down"
const inputLeft = "ui_left"
const inputRight = "ui_right"
const inputUseTool = "ui_accept"

const walkingSpeed = 10


#
# Properties
#
onready var animation_player = get_node("AnimationPlayer")


#
# Process
#
func _process(delta):
    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    match self.animation_player.current_animation:
        "Idle":
            if Input.is_action_pressed(inputUseTool):
                var targetPos = meta.callAncestorMethod(self, "playerToolSwingStart")
                var r = targetPos - self.position
                if r.x > 0: self.scale.x = 1
                if r.x < 0: self.scale.x = -1
                self.animation_player.play("SwingTool")

            else:
                _walk_or_idle(dx, dy, delta)

        "Walk":
            _walk_or_idle(dx, dy, delta)

        "SwingTool":
            pass

        _:
          self.animation_player.play("Idle")


#
# Input interrupts
#
func _unhandled_input(event):
    match self.animation_player.current_animation:
        "Idle":
            if event.is_pressed() and InputMap.event_is_action(event, inputUseTool):
                pass


#
# State helpers
#
func _walk_or_idle(dx, dy, delta):
    if dx or dy:
        var n = sqrt(dx * dx + dy * dy)

        self.position.x += dx / n * delta * walkingSpeed
        self.position.y += dy / n * delta * walkingSpeed

        self.animation_player.play("Walk")

        if dx < 0: self.scale.x = -1
        if dx > 0: self.scale.x = 1

    else:
        self.animation_player.play("Idle")
