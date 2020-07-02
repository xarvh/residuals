extends Node2D


const Storage = preload('res://src/Storage.gd')


#
# Config
#
const inputUp = "ui_up"
const inputDown = "ui_down"
const inputLeft = "ui_left"
const inputRight = "ui_right"
const inputUseTool = "ui_accept"

const inputNextTool = 'SelectNextTool'
const inputPrevTool = 'SelectPrevTool'

const walkingSpeed = 10

const backpackSize = 10


#
# Init
#
onready var animationPlayer = get_node("AnimationPlayer")
onready var viewportManager = Meta.getAncestor(self, 'ViewportManager')

onready var toolTargetCell = null

onready var backpackSelectedIndex = 0
onready var backpackStorage = Storage.new(backpackSize)

func _ready():
    backpackStorage.insertInFirstEmptySlot(Env.Item.Axe)
    backpackStorage.insertInFirstEmptySlot(Env.Item.Pickaxe)
    backpackStorage.insertInFirstEmptySlot(Env.Item.Wood)


#
# Process
#
func _process(delta):
    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    match self.animationPlayer.current_animation:
        "Idle":
            if Input.is_action_pressed(inputUseTool):
                # TODO check that the held item can be swung
                toolTargetCell = getTargetCell()
                var targetPos = (toolTargetCell + Vector2(0.5, 0.5)) * viewportManager.tilemap.cell_size
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
    # Selected item
    #
    animationPlayer.setHeldItem(viewportManager.itemToTexture(getSelectedBackpackItem()))



#
# Input interrupts
#
func _unhandled_input(event):
    if event.is_pressed():
        match self.animationPlayer.current_animation:
            "Idle", "Walk":
                if InputMap.event_is_action(event, inputNextTool):
                    backpackSelectedIndex = (backpackSelectedIndex + 1) % backpackSize

                if InputMap.event_is_action(event, inputPrevTool):
                    backpackSelectedIndex = ((backpackSelectedIndex + backpackSize - 1) % backpackSize)


#
# Hooks
#
func playerToolSwingHit():
    var targets = viewportManager.findAtCell(toolTargetCell)
    for t in targets:
        if t.has_method('onHitByTool'):
            t.onHitByTool(getSelectedBackpackItem(), self)


func getTargetCell():
    var mouse_cell = Meta.callAncestorMethod(self, 'getMouseCell')
    var player_cell = viewportManager.positionToCell(position)
    return (mouse_cell - player_cell).clamped(sqrt(2)).round() + player_cell


func collectItem(type):
    var collect = get_node('Collect')
    if not collect.playing or collect.get_playback_position() > 0.05:
        collect.play()


#
# State helpers
#
func getSelectedBackpackItem():
    return backpackStorage.items[backpackSelectedIndex]


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
