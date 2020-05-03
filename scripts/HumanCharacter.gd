extends Node2D


# stuff that can be set from the outside
var directionIsLeft = true
var walkingSpeed = 1

# config stuff
var armSwingAmplitude = 0.05 * PI
var armAngleOffset = -0.01 * PI

# internal stuff
var time = 0

var spriteLegs
var spriteHead
var spriteArm

func _ready():
    self.spriteLegs = self.get_node('Legs')
    self.spriteHead = self.spriteLegs.get_node('Head')
    self.spriteArm = self.spriteHead.get_node('Arm')


func _process(delta):
    time += delta

    var legsFrame
    var armAngle
    if walkingSpeed == 0:
        legsFrame = 1

        armAngle = armAngleOffset

    else:
        # TODO update directionIsLeft
        # TODO scale x according to directionIsLeft
        var totalFrames = 6

        # TODO ensure that duration is consistent with the pixel-per-second velocity
        var duration = 1
        var normalizedTime = fposmod(time, duration) / duration

        legsFrame = floor(normalizedTime * (totalFrames - 1))

        armAngle = armAngleOffset + armSwingAmplitude * sin(2 * PI * normalizedTime + 0.25 * PI)


    self.spriteArm.rotation = armAngle

    self.spriteLegs.frame = legsFrame
