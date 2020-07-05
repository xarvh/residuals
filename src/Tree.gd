extends Node2D


#
# Config
#
const trunkShakeDuration = 0.5
const trunkShakeAmplitude = 0.005 * PI
const trunkShakeSpeed = 10 * PI

const totalTimeToFall = 1.5

const stumpShakeDuration = 0.1
const stumpShakeAmplitude = 1
const stumpShakeSpeed = 10 * PI

const trunkHp = 40
const stumpHp = 40


#
#
#
onready var trunk = get_node('Trunk')
onready var stump = get_node('Stump')
onready var axeOnWood = get_node('AxeOnWood')
onready var treeFalls = get_node('TreeFalls')

enum State {
    TrunkUp
    TrunkFalling
    Stump
}

onready var state = State.TrunkUp if trunk else State.Stump
onready var damage = 0
onready var timeLeftToShake = 0
onready var timeSinceFallingStart = 0


func _process(dt):

    if timeLeftToShake > 0:
        timeLeftToShake -= dt
        if state == State.TrunkUp:
            trunk.rotation = trunkShakeAmplitude * (timeLeftToShake / trunkShakeDuration) * sin(timeLeftToShake * trunkShakeSpeed)
        else:
            stump.position.x = stumpShakeAmplitude * (timeLeftToShake / stumpShakeDuration) * sin(timeLeftToShake * stumpShakeSpeed)

    if state == State.TrunkFalling:
        timeSinceFallingStart += dt
        if timeSinceFallingStart < totalTimeToFall:
            var t = timeSinceFallingStart / totalTimeToFall
            trunk.rotation = 0.5 * PI * t * t
        else:
            state = State.Stump
            treeFalls.stop()
            # TODO play "poof" sound?
            # TODO spawn a lot of leaves
            for i in Env.rng.randi_range(12, 16):
                var pos = self.position
                pos.x += Env.rng.randf_range(0.5, 4) * Env.cellSize
                Meta.callAncestorMethod(self, "spawnDrop", [ pos, Env.ItemId.Wood ])
            trunk.queue_free()
            trunk = null


func onHitByTool(itemId, player):

    if itemId != Env.ItemId.Axe:
        # TODO make a thud sound
        return

    axeOnWood.play()
    damage += 10

    match state:
        State.TrunkUp:
            if damage < trunkHp:
                timeLeftToShake = trunkShakeDuration
            else:
                state = State.TrunkFalling
                timeLeftToShake = 0
                damage = 0
                treeFalls.play()

        _:
            if damage < stumpHp:
                timeLeftToShake = stumpShakeDuration
            else:
                for i in Env.rng.randi_range(4, 9):
                    Meta.callAncestorMethod(self, "spawnDrop", [ self.position, Env.ItemId.Wood ])
                self.queue_free()
                # TODO make breaking sound

