extends KinematicBody2D


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
    backpackStorage.insertInFirstEmptySlot(Env.ItemId.Hoe)
    backpackStorage.insertInFirstEmptySlot(Env.ItemId.Axe)
    backpackStorage.insertInFirstEmptySlot(Env.ItemId.Pickaxe)
    backpackStorage.insertInFirstEmptySlot(Env.ItemId.Wood)
    backpackStorage.insertInFirstEmptySlot(Env.ItemId.CauliflowerSeeds)


#
# Process
#
func _process(delta):
    #
    # Selected item
    #
    animationPlayer.setHeldItem(getSelectedBackpackItemId())



func _physics_process(delta):
    var dx = -1 if Input.is_action_pressed(inputLeft) else 1 if Input.is_action_pressed(inputRight) else 0
    var dy = -1 if Input.is_action_pressed(inputUp) else 1 if Input.is_action_pressed(inputDown) else 0

    match self.animationPlayer.current_animation:
        "Idle":
            if Input.is_action_pressed(inputUseTool) and getSelectedBackpackItem().use == Env.ItemUse.Swing:
                toolTargetCell = getTargetCell()
                var targetPos = (toolTargetCell + Vector2(0.5, 0.5)) * viewportManager.tileMap.cell_size
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
    var itemId = getSelectedBackpackItemId()
    var targets = viewportManager.findAtCell(toolTargetCell)
    var targetHit = false
    for t in targets:
        if t.has_method('onHitByTool'):
            t.onHitByTool(itemId, self)
            targetHit = true

    if not targetHit and itemId == Env.ItemId.Hoe:
        viewportManager.hoeHitsGround(toolTargetCell)


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
func getSelectedBackpackItemId():
    return backpackStorage.items[backpackSelectedIndex]


func getSelectedBackpackItem():
    return Env.itemsById[getSelectedBackpackItemId()]


func _walk_or_idle(dx, dy, delta):
    if dx or dy:
        self.move_and_slide(Vector2(dx, dy).normalized() * walkingSpeed)

        self.animationPlayer.play("Walk")

        if dx < 0: self.get_node('Legs').scale.x = -1
        if dx > 0: self.get_node('Legs').scale.x = 1

    else:
        self.animationPlayer.play("Idle")
