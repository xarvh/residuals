extends Node2D


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
onready var animationPlayer = get_node("AnimationPlayer")
onready var mapManager = Meta.getAncestor(self, 'MapManager')

onready var toolTargetCell = null


#
# Process
#
func _process(delta):
    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    match self.animationPlayer.current_animation:
        "Idle":
            if Input.is_action_pressed(inputUseTool):
                toolTargetCell = getTargetCell()
                var targetPos = (toolTargetCell + Vector2(0.5, 0.5)) * mapManager.tilemap.cell_size
                var r = targetPos - self.position
                if r.x > 0: self.scale.x = 1
                if r.x < 0: self.scale.x = -1
                self.animationPlayer.play("SwingTool")

            else:
                _walk_or_idle(dx, dy, delta)

        "Walk":
            _walk_or_idle(dx, dy, delta)

        "SwingTool":
            pass

        _:
          self.animationPlayer.play("Idle")


#
# Input interrupts
#
func _unhandled_input(event):
    match self.animationPlayer.current_animation:
        "Idle":
            if event.is_pressed() and InputMap.event_is_action(event, inputUseTool):
                pass


#
# Hooks
#
func playerToolSwingHit():
    var axePower = 10
    var targets = mapManager.findAtCell(toolTargetCell)
    for t in targets:
        if t.has_method('onHitByTool'):
            t.onHitByTool('axe', axePower, self)


func getTargetCell():
    var mouse_cell = Meta.callAncestorMethod(self, 'getMouseCell')
    var player_cell = mapManager.positionToCell(position)
    return (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell



#
# State helpers
#
func _walk_or_idle(dx, dy, delta):
    if dx or dy:
        var n = sqrt(dx * dx + dy * dy)

        self.position.x += dx / n * delta * walkingSpeed
        self.position.y += dy / n * delta * walkingSpeed

        self.animationPlayer.play("Walk")

        if dx < 0: self.scale.x = -1
        if dx > 0: self.scale.x = 1

    else:
        self.animationPlayer.play("Idle")
