extends Node2D


#
# stuff that can be set from the outside
#
var walkingSpeed = 1


func startSwinging():
    swingToolEndTime = time + armToolSwingDuration


#
# config stuff
#

# walking / idle
var armSwingAmplitude = 0.05 * PI
var armAngleOffset = -0.01 * PI
var walkedDistancePerWalkCycle = 6
var framesPerWalkCycle = 6

# tool swinging
var armToolSwingDuration = 1
var armToolSwingStartAngle = deg2rad(-124)
var armToolSwingEndAngle = deg2rad(-16.4)



#
# internal stuff
#
var time = 0
var swingToolEndTime = 0

var spriteLegs
var spriteHead
var spriteArm

func _ready():
    self.spriteLegs = self.get_node('Legs')
    self.spriteHead = self.spriteLegs.get_node('Head')
    self.spriteArm = self.spriteHead.get_node('Arm')

    self.startSwinging()


func _process(delta):
    time += delta

    var legsFrame
    var armAngle
    if swingToolEndTime > time:
        # Animation: tool swing
        legsFrame = 1

        var dt = (swingToolEndTime - time) / armToolSwingDuration
        var s = armToolSwingStartAngle
        var e = armToolSwingEndAngle
        armAngle = s + (e - s) * (1 - dt) * (1 - dt)

    else: if walkingSpeed == 0:
        # Animation: idle
        legsFrame = 1

        armAngle = armAngleOffset

    else:
        # Animation: walk
        var duration = walkedDistancePerWalkCycle / float(abs(walkingSpeed))
        var normalizedTime = fposmod(time, duration) / duration

        legsFrame = floor(normalizedTime * (framesPerWalkCycle - 1))

        armAngle = armAngleOffset + armSwingAmplitude * sin(2 * PI * normalizedTime + 0.25 * PI)


    self.spriteArm.rotation = armAngle

    self.spriteLegs.frame = legsFrame
